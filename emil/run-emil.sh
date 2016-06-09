#!/bin/bash
set -x

DOCKER=eaas/bwfla:emil

USAGE='MAKE SURE TO USE CORRECT COMMAND-LINE (SET MANDATORY ARGS, ANY SPECIFIED DIRS MUST EXIST)
./run-demo   --public-ip-port <PUBLIC_IP:PORT> (PORT >= 8080, DEFAULT: 8080)
             --iframe-ip-port <PUBLIC_IP:PORT>
             --archive-dir <IMAGE_ARCHIVE>
             --objects <OBJECT_ARCHIVE>
             --environments-dir <ENVIRONMENTS_DIR>'

if [ $(($# % 2)) -ne 0 ]
then
    echo "$USAGE"
    exit 50
fi

abspath()
{
    if [[ -d "$1" ]]
    then
        cd "$1" &> '/dev/null' && echo "$(pwd -P)" && exit 0
    else 
        cd &> '/dev/null' "$(dirname "$1")" && echo "$(pwd -P)/$(basename "$1")" && exit 0
    fi

    exit 30
}

while [ $# -gt 1 ]
do
    case $1 in
        --public-ip-port)
            IFS=':' read -a PUBLIC_IP_PORT <<< "$2"
            PUBLIC_IP=${PUBLIC_IP_PORT[0]}
            PUBLIC_PORT=${PUBLIC_IP_PORT[1]}
            ;;

        --iframe-ip-port)
            IFS=':' read -a IFRAME_IP_PORT <<< "$2"
            IFRAME_IP=${IFRAME_IP_PORT[0]}
            IFRAME_PORT=${IFRAME_IP_PORT[1]}
            ;;

	--archive-dir)
            ARCHIVE_DIR="$(abspath $2)"
            ;;

        --objects)
            OBJECTS_DIR="$(abspath $2)"
            ;;

        --environments-dir)
            ENVIRONMENTS_DIR="$(abspath $2)"
            ;;

        *) # DEFAULT
            echo "skipping unrecognized option $1"
            ;;
    esac

    shift 2
done

if [ -z "$DOCKER" ] || [ -z "$PUBLIC_IP" ] || [ -z "$PUBLIC_PORT" ] || [ -z "$ARCHIVE_DIR" ]
then
    echo -e "$USAGE"
    exit 50
fi

if [ -z "$IFRAME_IP" ]
then
    IFRAME_IP=$PUBLIC_IP
fi

if [ -z "$IFRAME_PORT" ]
then
    IFRAME_PORT=$PUBLIC_PORT
fi

if [ -n "$ENVIRONMENTS_DIR" ]
then 
    if [ -d "$ENVIRONMENTS_DIR" ]
    then
        ATTACHMENT="$ATTACHMENT -v $ENVIRONMENTS_DIR:/home/bwfla/emil-environments"
    #else
        #echo -e "$USAGE" 
        #exit 51
    fi
fi

if [ -n "$SWARCHIVE_DIR" ]
then 
    if [ -d "$SWARCHIVE_DIR" ]
    then
        ATTACHMENT="$ATTACHMENT -v $SWARCHIVE_DIR:/home/bwfla/emil-software-archive"
    else
        echo -e "$USAGE" 
        exit 51
    fi
fi

if [ -n "$OBJ_META_DIR" ]
then 
    if [ -d "$OBJ_META_DIR" ]
    then
        ATTACHMENT="$ATTACHMENT -v $OBJ_META_DIR:/home/bwfla/object-metadata"
    else
        echo -e "$USAGE" 
        exit 51
    fi
fi

if [ -n "$OBJECTS_DIR" ]
then
    if [ -d "$OBJECTS_DIR" ]
    then
        ATTACHMENT="$ATTACHMENT -v $OBJECTS_DIR:/home/bwfla/user-objects"
    else
        echo -e "$USAGE" 
        exit 52
    fi
fi

if [ -n "$SWARCHIVE_STORAGE_DIR" ]
then
    if [ -d "$SWARCHIVE_STORAGE_DIR" ] 
    then
        ATTACHMENT="$ATTACHMENT -v $SWARCHIVE_STORAGE_DIR:/home/bwfla/software-archive/storage"
    else
        echo -e "$USAGE"
        exit 55
    fi
fi

if [ -n "$SWARCHIVE_INCOMING_DIR" ]
then
    if [ -d "$SWARCHIVE_INCOMING_DIR" ]
    then
        ATTACHMENT="$ATTACHMENT -v $SWARCHIVE_INCOMING_DIR:/home/bwfla/software-archive/incoming"
    else
        echo -e "$USAGE"
        exit 56
    fi
fi

set -e
releaseContainer()
{
    RET=$?
    set +e

    if [ -n "$CONTAINER" ]
    then
        docker rm -f "$CONTAINER" 1> /dev/null
    fi

    return $RET
}

#docker pull "$DOCKER"

CONTAINER="bwFLA-Container_$$"
ATTACHMENT="$ATTACHMENT -v $ARCHIVE_DIR:/home/bwfla/image-archive"
docker run --privileged=true -p "$PUBLIC_IP:$PUBLIC_PORT:8080" -p 1080:80 -p 10809:10809 -d $ATTACHMENT --name "$CONTAINER" --net bridge -it "$DOCKER" bash
trap releaseContainer EXIT QUIT INT TERM

CPUS=2
ENDPOINT=$PUBLIC_IP:$PUBLIC_PORT
NODES="           <node>
                    <address>http://$ENDPOINT/emucomp</address>
                    <nodespecs>
                        <cpucores>$CPUS</cpucores>
                        <memory>4096</memory>
                        <disk>100</disk>
                    </nodespecs>
                  </node>
               "
docker exec -it "$CONTAINER" perl -pe "s#%NODES%#$NODES#g" -i '/home/bwfla/.bwFLA/EaasConf.xml'
docker exec -it "$CONTAINER" sed -r "s#%PUBLIC_IP%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/ImageArchiveConf.xml'
docker exec -it "$CONTAINER" sed -r "s#%PUBLIC_IP%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/EmucompConf.xml'
docker exec -it "$CONTAINER" sed -r "s#%PUBLIC_IP%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/ObjectArchiveConf.xml'
docker exec -it "$CONTAINER" sed -r "/<embedGw/s#%PUBLIC_IP%#$IFRAME_IP:$IFRAME_PORT#g" -i '/home/bwfla/.bwFLA/EmilConf.xml'
docker exec -it "$CONTAINER" sed -r "s#%PUBLIC_IP%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/EmilConf.xml'
docker exec -it "$CONTAINER" sed -r "/<controlUrlAddress/s#%PUBLIC_IP%#$IFRAME_IP:$IFRAME_PORT#g" -i '/home/bwfla/.bwFLA/EmucompConf.xml'
docker exec -it "$CONTAINER" sed -r "/eaasBackendURL/s#localhost:8080#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/etc/emil/emil-ui.json'
docker exec -it "$CONTAINER" sed -r "/eaasBackendURL/s#localhost:8080#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/etc/emil/emil-admin-ui.json'

docker exec -it "$CONTAINER" sed "s#%IMAGE_ARCHIVE%#$PUBLIC_IP:$PUBLIC_PORT#g;s#%EAAS_GATEWAY%#$PUBLIC_IP:$PUBLIC_PORT#g;s#%OBJECT_ARCHIVE%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/WorkflowsConf.xml'

docker exec -it "$CONTAINER" sed "s#%PUBLIC_IP%#$PUBLIC_IP:$PUBLIC_PORT#g" -i '/home/bwfla/.bwFLA/WorkflowsConf.xml'

docker exec -it "$CONTAINER" sed -r 's#(<modify-wsdl-address>).*(</modify-wsdl-address>)#\1true\2#'                            -i '/home/bwfla/appserver/standalone/configuration/standalone.xml'
docker exec -it "$CONTAINER" sed -r "s#(<wsdl-host>).*(</wsdl-host>)#\1$PUBLIC_IP\2#"                                          -i '/home/bwfla/appserver/standalone/configuration/standalone.xml'
docker exec -it "$CONTAINER" sed -r "/<modify-wsdl-address>.*<\/modify-wsdl-address>/a \\\\t<wsdl-port>$PUBLIC_PORT</wsdl-port>" -i '/home/bwfla/appserver/standalone/configuration/standalone.xml'
docker exec -it "$CONTAINER" usermod -u 1000 bwfla
docker exec -it "$CONTAINER" service apache2 start
#docker exec -it "$CONTAINER" bash
docker exec -it "$CONTAINER" bash '/home/bwfla/flavor-start'

echo "FINISHED!"
