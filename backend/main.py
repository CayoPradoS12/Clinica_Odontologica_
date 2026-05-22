from fastapi import FastAPI
from fastapi.middleware.cors import  CORSMiddleware
import mysql.connector
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials= True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def conectar_banco():
    return mysql.connector.connect(
        host="localhost",
        user="app_odontoped_user",
        password="DevClinica2026!",
        database="clinica_odontologica"
    )
@app.get("/api/agenda")
def listar_agenda():
    conexao = conectar_banco()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_agenda_completa ORDER BY data_hora DESC")
    dados_da_view = cursor.fetchall()

    cursor.close()
    conexao.close()
    return dados_da_view