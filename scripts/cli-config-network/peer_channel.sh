#!/bin/sh
export CHANNEL_NAME=marketplace
## Creamos el canal con los credenciales del orderer.
peer channel create -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ../channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem
mv marketplace.block ../
# Unir a la primera organizacion al canal marketplace, como cli tiene la identidad no hace falta especificar nada mas
peer channel join -b ../marketplace.block
# Unir a la segunda organizacion y la tercera al canal marketplace, como cli no tiene la identidad hay que pasarle el material cryptografico de la segunda organizacion.
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/users/Admin@consumidor.acme.com/msp CORE_PEER_ADDRESS=peer0.consumidor.acme.com:7051 CORE_PEER_LOCALMSPID="consumidorMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/peers/peer0.consumidor.acme.com/tls/ca.crt  peer channel join -b ../marketplace.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/users/Admin@mayorista.acme.com/msp CORE_PEER_ADDRESS=peer0.mayorista.acme.com:7051 CORE_PEER_LOCALMSPID="mayoristaMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt  peer channel join -b ../marketplace.block
