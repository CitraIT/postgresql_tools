#!/usr/bin/python3
-*- coding: utf-8 -*-
# Citra IT - Excelencia em TI
# Script to query all tables from a given database to calculate each relation size
# @Author: luciano@citrait.com.br
# @Version: 1.0
import sys
try:
  import psycopg2
except:
  print(f'you need psycopg2 installed to run this script.')
  print(f'please, install it with python3 -m pip install psycopg2-binary and try again.')
  sys.exit(0)



DB_SERVER = 'ip-address-of-postgres-server'
DB_PORT = 5432
DB_USER = 'user-of-db-server'
DB_PASSWORD = 'pass-of-db-server'
DB_DATABASE = 'database-to-query-tables'


def main() -> None:
    # Conecta no banco
    conn = psycopg2.connect(
        host=DB_SERVER,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_DATABASE
    )
    cursor = conn.cursor()

    # abre o arquivo com a lista de tabelas
    print(f"tabela,tamanho")
    cursor.execute("SELECT CONCAT(table_schema,'.',table_name) AS table FROM information_schema.tables WHERE table_schema not in ('pg_catalog','public','information_schema')")
    all_tables = cursor.fetchall()
    for table in all_tables:
        cursor.execute(f"SELECT pg_size_pretty(pg_total_relation_size({table}))")
        #cursor.execute(f"SELECT pg_total_relation_size(%s)", (table,))
        result = cursor.fetchone()[0]
        print(f"{table},{result}")

    cursor.close()
    conn.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f'OCORREU O SEGUINTE ERRO AO PROCESSAR O SCRIPT:')
        print(str(e))
        sys.exit(0)
