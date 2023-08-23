#!/usr/bin/env python3
import socket

# 
TARGET_ADDRESS = '192.168.0.1'
TARGET_PORT    =  5432

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    s.settimeout(3)
    s.connect((TARGET_ADDRESS, TARGET_PORT))
    print(f'conectado com sucesso')
except Exception as e:
    print(f'erro ao conectar.')
    print(str(e))
