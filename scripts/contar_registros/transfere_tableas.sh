#!/bin/bash
# Citra IT - Excelencia em TI
# Script para sincronizar dados do postgres entre dois servidores
# @Author: luciano@citrait.com.br
# @Date: 23/08/2023
#set -x

# Variaveis importantes
LOGFILE=/var/log/dbsync.log
FILETABELAS=tabelas.txt
PSQL=`which psql`
TZ="America/Sao_Paulo"

LOCAL_DBHOST="localhost"
LOCAL_DBPORT="5432"
LOCAL_DBNAME="testdb"
LOCAL_DBUSER="postgres"
LOCAL_DBPASS="postgres"

REMOTE_DBHOST=""
REMOTE_DBPORT="5432"
REMOTE_DBNAME=""
REMOTE_DBUSER=""
REMOTE_DBPASS=""




function justexit(){
        echo "saindo..."
        exit 1
}

# happens :x
trap justexit SIGINT


function log(){
        echo "$(TZ=$TZ date -Iseconds) $1" | tee -a $LOGFILE
}

function raw_log(){
        echo "$1" | tee -a $LOGFILE
}

function psql_local_command(){
    PGPASSWORD=$LOCAL_DBPASS $PSQL -c "$1" -h $LOCAL_DBHOST -p $LOCAL_DBPORT -U $LOCAL_DBUSER -d $LOCAL_DBNAME
}
function psql_remote_command(){
    PGPASSWORD=$REMOTE_DBPASS $PSQL -c "$1" -h $REMOTE_DBHOST -p $REMOTE_DBPORT -U $REMOTE_DBUSER -d $REMOTE_DBNAME

}

function psql_sv_remote_command(){
    PGPASSWORD=$SV_DBPASS $PSQL -c "$1" -h $SV_DBHOST -p $SV_DBPORT -U $SV_DBUSER -d $SV_DBNAME

}


#-----------------------------------------------
# main routine starts here
#-----------------------------------------------
log "------- SCRIPT PARA SINCRONIZACAO DB -------"
log "@Autor: luciano@citrait.com.br"
log "@Version: 1.0 baby born"
log "------------------------------------------------------------"
log "------------=====================================------------"
log "iniciando o script de sincronizacao..."

log "procurando pelo arquivo com a lista de tabelas..."
if [ -f $FILETABELAS ]; then
        log "arquivo $FILETABELAS encontrado com sucesso"
else
        log "erro ao encontrar o arquivo $FILETABELAS"
        log "saindo devido a uma condicao critica :x"
        exit 1
fi


# heavy work
for tbl in $(cat $FILETABELAS)
do
        log "sincronizando a tabela ${tbl}"
        log "desabilitando triggers para ${tbl}"
        psql_local_command "ALTER TABLE ${tbl} DISABLE TRIGGER ALL"

        log "deletando dados para ${tbl}"
        psql_local_command "DELETE FROM ${tbl}"

        log "copiando dados para ${tbl}..."
        psql_remote_command "COPY (SELECT * FROM ${tbl}) TO STDOUT" \
                | psql_local_command "COPY ${tbl} FROM STDIN"

        log "habilitando triggers para ${tbl}"
        psql_local_command "ALTER TABLE ${tbl} ENABLE TRIGGER ALL"

        log "finalizado sincronizacao da tabela ${tbl}"
done


log "==================================================================="


# leave gracefuly
log "finalizado execucao do script."


