#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import random
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = 'ist199321'
DB_DATABASE = DB_USER
DB_PASSWORD = 'elefantecarrifante'
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)

@app.route("/categories", methods=['GET', 'POST'])
def categories():
    dbConn = None
    cursor = None
    error = None
    if request.method == 'POST' and 'remove' in request.form:
        error = remove_category()
    if request.method == 'POST' and 'add' in request.form:
        add_category()
    if request.method == 'POST' and 'add-sub' in request.form:
        add_sub_category()
    if request.method == 'POST' and 'list' in request.form:
        cursor_two = list_sub_categories()
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor_options = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT category_name, super_category FROM category c LEFT JOIN has_other h ON h.child_category = c.category_name;"
        cursor.execute(query)
        cursor_options.execute(query)
        if error:
             return render_template("categories.html", cursor=cursor, cursor_options= cursor_options, error=error)
        if 'list' in request.form:
            if cursor_two.rowcount != 0:
                return render_template("categories.html", cursor=cursor, cursor_two = cursor_two, cursor_options=cursor_options, name= request.form['list'])
            return render_template("categories.html", cursor=cursor, error = True, cursor_options=cursor_options, name= request.form['list'])
        return render_template("categories.html", cursor=cursor, cursor_options=cursor_options)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

def remove_category():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        START TRANSACTION;
        CALL delete_cat(%s);
        commit;
        """
        data = (request.form['category_name'],)
        cursor.execute(query, data)
        return
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

def add_category():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        START TRANSACTION;
        INSERT INTO category values(%s);
        commit;
        """
        data = (request.form['category_name'],)
        cursor.execute(query, data)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

def add_sub_category():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        START TRANSACTION;
        CALL add_sub(%s, %s);
        commit;
        """
        data = (request.form.get('sub'), request.form['category_name'])
        cursor.execute(query, data)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

def list_sub_categories():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor_two = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        SELECT * FROM list_subs(%s);
        """
        data = (request.form['list'],)
        cursor_two.execute(query, data)
        return cursor_two
    except Exception as e:
        return str(e)

@app.route("/", methods=['GET', 'POST'])
def retailers():
    dbConn = None
    cursor = None
    if request.method == 'POST' and 'remove' in request.form:
        remove_retailer()
    if request.method == 'POST' and 'add' in request.form:
        add_retailer()
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM retailer;"
        cursor.execute(query)
        return render_template("retailers.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


def refresh_db():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor_refresh = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        START TRANSACTION;
        \i ivm.sql
        \i carregamento.sql
        COMMIT;
        """
        cursor_refresh.execute(query)
    except Exception as e:
        return str(e)

def remove_retailer():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """
        START TRANSACTION;
        DELETE FROM responsible_for WHERE retailer_tin='%s';
        DELETE FROM replenishment_event WHERE retailer_tin='%s';
        DELETE FROM retailer WHERE retailer_tin='%s';
        commit;
        """

        data = tuple([int(request.form['retailer_tin']) for i in range(3)])
        cursor.execute(query, data)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

def add_retailer():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        new_tin = request.form['retailer_tin'] if request.form['retailer_tin'] else str(90) + str(random.randint(0000000, 9999999))    
        query = """
        START TRANSACTION;
        INSERT INTO retailer values(%s,%s);
        commit;
        """
        data = (new_tin, request.form['retailer_name'])
        cursor.execute(query, data)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/ivms", methods=['GET', 'POST'])
def list_ivms():
    dbConn = None
    cursor = None
    if request.method == 'POST':
        (serial, cursor_two, cursor_three) = fetch_ivm_info()
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM ivm;"
        cursor.execute(query)
        if request.method == 'POST':
            return render_template("ivms.html", serial = serial, cursor=cursor, cursor_two=cursor_two, cursor_three=cursor_three)
        return render_template("ivms.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()
    
def fetch_ivm_info():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor_two = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query_two = "SELECT product_ean, category_name, replenished_units, shelf_nr, event_instant, retailer_tin FROM replenishment_events_for_ivm WHERE ivm_serial_number = %s AND ivm_manuf = %s"
        data_two = (request.form['serial'], request.form['manuf'])
        cursor_two.execute(query_two, data_two)
        cursor_three = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query_three = "SELECT COALESCE(product_ean, 'Total') AS product_ean, category_name, SUM(replenished_units) FROM replenishment_events_for_ivm WHERE ivm_serial_number=%s AND ivm_manuf = %s GROUP BY category_name, ROLLUP(product_ean);"
        data_three = (request.form['serial'], request.form['manuf'])
        cursor_three.execute(query_three, data_three)
        return (request.form['serial'], cursor_two, cursor_three)
    except Exception as e:
        return str(e)

CGIHandler().run(app)
