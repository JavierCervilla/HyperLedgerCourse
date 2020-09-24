#!bin/sh

#instanciamos las variables a utilizar

export CHANNEL_NAME=marketplace
export CHAINCODE_NAME=datacontrol
export CHAINCODE_VERSION=1
export CC_RUNTIME_LANGUAGE=golang
export CC_SRC_PATH="/opt/gopath/src/github.com/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

# empaquetamos el contrato en un tar que swera el que tendran que instalar las diferentes organizaciones:
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

###################################################################################################
#   INSTALACION:
#       para todas las organizaciones.
###################################################################################################
# instalamos el contrato para la organizacion numero 1: productor

peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

# es necesario guardar el hash para el commit posterior
export CC_PACKAGEID=datacontrol_1:6ff99d364de74c025219cd2075f41ecda88c086c7006bbf5f2560274708d3f20

# guardamos el hash para comprobar las distintas instalaciones en la red
# Chaincode code package identifier: datacontrol_1:6ff99d364de74c025219cd2075f41ecda88c086c7006bbf5f2560274708d3f20

# Ahora hay que instalar el tar.gz en el resto de organizaciones con sus credenciales correspondientes
# Organizacion 2 : consumidor

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/users/Admin@consumidor.acme.com/msp CORE_PEER_ADDRESS=peer0.consumidor.acme.com:7051 CORE_PEER_LOCALMSPID="consumidorMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/peers/peer0.consumidor.acme.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

# comprobamos que el hash corresponda con el que tenemos guardado
# Chaincode code package identifier: datacontrol_1:6ff99d364de74c025219cd2075f41ecda88c086c7006bbf5f2560274708d3f20

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/users/Admin@mayorista.acme.com/msp CORE_PEER_ADDRESS=peer0.mayorista.acme.com:7051 CORE_PEER_LOCALMSPID="mayoristaMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

# comprobamos el hash con los dos anteriores
# Chaincode code package identifier: datacontrol_1:6ff99d364de74c025219cd2075f41ecda88c086c7006bbf5f2560274708d3f20



###################################################################################################################
#   POLITICAS DE ENDORSAMIENTO:
#       para las organizaciones productor y mayorista.
#       el consumidor no podra escribir en este chaincode.
###################################################################################################################

# aprovamos para la primera organizacion la politica de endorsamiento y verificamos:

peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --package-id $CC_PACKAGEID
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --output json

# aprovamos las politicas para la organizacion mayorista y verificamos:

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/users/Admin@mayorista.acme.com/msp  CORE_PEER_ADDRESS=peer0.mayorista.acme.com:7051  CORE_PEER_LOCALMSPID="mayoristaMSP"  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt  peer lifecycle chaincode approveformyorg --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --package-id $CC_PACKAGEID
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --output json

###################################################################################################################
#   COMMIT DEL CHAINCODE:
#       para todas las organizaciones.
###################################################################################################################

peer lifecycle chaincode commit -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA --peerAddresses peer0.productor.acme.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/productor.acme.com/peers/peer0.productor.acme.com/tls/ca.crt --peerAddresses peer0.mayorista.acme.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')"