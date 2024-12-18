#En este script se explicará como crear un backup de una instancia web en EC2 hacia un bucket S3

#Para empezar a crear se deben añadir las credenciales de la API de AWS a la instancia desde la que se van a hacer las backups

#Las credenciales se encuentran en el AwsDetails. Para acceder hay que presionar en "Show" en AWS ClI

#Estas credenciales se deben guardar en ~/.aws/credentials tal cual a como indica Amazon básicamente hay que hacer un copia-pega de esas credenciales en el fichero que se crea

#Se debe crear el fichero con sudo obligatorio ya que se esta creando un ficero oculto al cuál solo el script podrá acceder.

#Antes de ir con el script se debe instalar en la instancia "AWS-CLI" para que el script pueda acceder a ese fichero oculto de credenciales.

#El comando de instalación es el siguiente: Sudo apt install aws-cli.

#Una vez se ha instalado el cli se debe configurar la región, el formato de salida y las claves.

#El comando que se debe ejecutar es: aws configure. Este comando pedirá aws_access_key_id, aws_secret_access_key, region (La región del laboratorio, que se encuentra al final del todo en AWS-Details.) y el formato de salida (Json, Text, XML etc..)

#Una vez configurado todo eso se procede con el script el cuál es el siguiente:

            #!/bin/bash

              #Backup hacia el bucket
                BUCKET_NAME="nombre_bucket"   #Define el nombre del bucket de S3 donde se subirá el archivo
                FOLDER_PATH="/var/www/html"   #Ruta del directorio que se desea respaldar en este caso como se quiere hacer un backup de la página web se copia todo el html.
                TIMESTAMP=$(date "+%Y_%m_%d-%H:%M")   #Genera una marca de tiempo (formato YYYY_MM_DD-HH:MM) para distinguir los backups.
                BACKUP="/tmp/backup_${TIMESTAMP}.zip"   #Ruta y nombre del archivo ZIP que se creará en la carpeta temporal /tmp

              #Creación del zip
                zip -r "$BACKUP" "$FOLDER_PATH"   #Se utiliza el comando zip -r para comprimir de manera recursiva (que copie todo lo que hay dentro de ese directorio) el contenido del directorio definido en FOLDER_PATH.


              #Comprobar la creación del zip

                if [ -f "$BACKUP" ]; then     #Se verifica si el archivo ZIP fue creado correctamente comprobando si existe (-f).
                        echo "Se creó el backup : $BACKUP"  #Si existe, se imprime un mensaje indicando que se generó el archivo

            #Mandar el backup al bucket usando el CLI
                        aws s3 cp "$BACKUP" "s3://$BUCKET_NAME/"   #Utiliza el comando aws s3 cp para copiar el archivo ZIP al bucket de S3 indicado.
                                                                  #aws-cli debe estar configurado previamente con las credenciales necesarias.

            #Comprobar que se envió de manera correcta
                    if [ $? -eq 0  ]; then   #Verifica si el comando anterior (aws s3 cp) se ejecutó correctamente. $? almacena el código de salida del último comando ejecutado: 0: Éxito. Distinto de 0: Error.
                            echo "Backup subido a $BUCKET_NAME"   #Si la subida fue exitosa, se imprime un mensaje confirmándolo.

                    #Eliminar el backup local
                            rm "$BACKUP"   #Si el archivo fue subido correctamente a S3, se elimina el archivo ZIP local para liberar espacio.
                    else
                          echo "Error al subir el backup"   #Si la subida a S3 falla
                    fi
                else
                          echo "Error al crear el zip"   #Si no se pudo crear el ZIP
                fi


#Una vez se ha creado el fichero del script se debe ejecutar el comando: sudo chmod +x. Esto con el fin de que sea ejecutable.

#Una vez se ejecute el script deberán salir lo siguiente:

#        ./htmlBackup.sh 
#        adding: var/www/html/ (stored 0%)
#        adding: var/www/html/index.html (deflated 71%)
#        Se creó el backup : /tmp/backup_2024_11_23-16:54.zip
#        upload: ../../tmp/backup_2024_11_23-16:54.zip to s3://bucketweb/backup_2024_11_23-16:54.zip
#        Backup subido a bucketweb

#Posibles errores que pueden surgir

#En caso de que salga este error: An error occurred (ExpiredToken) when calling the PutObject operation: The provided token has expired

#Se deben ejecutar los siguientes comandos:
  
#export AWS_ACCESS_KEY_ID="clave de acceso"
#export AWS_SECRET_ACCESS_KEY="clave secreta"
#export AWS_SESSION_TOKEN="token de sesión"

#Todo esto es lo que ya esta previamente añadido pero aveces el AWS-CLI se queda "medio tonto" y no ve lo que hay en el fichero por que esta buscando en su caché
 # por lo que ejecutando esos comandos se actualizará y se podrá ejecutar el script perfectamente.
