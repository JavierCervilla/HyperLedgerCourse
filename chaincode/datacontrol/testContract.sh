#!bin/sh

export CHANNEL_NAME=marketplace
export CHAINCODE_NAME=datacontrol
export CHAINCODE_VERSION=1
export CC_RUNTIME_LANGUAGE=golang
export CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem


############################################################################
#chaincode is committed and useable in the fabric network
#INIT LEDGER
#peer chaincode invoke -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA -C  $CHANNEL_NAME  -n $CHAINCODE_NAME -c '{"Args":["InitLedger"]}'
#productor invokes set() with key “data:1” and value “........”.
peer chaincode invoke -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA -C $CHANNEL_NAME  -n $CHAINCODE_NAME -c '{"Args":["Set","data:1","Javier","Madrid","SmartContracts","Blockchain","1"]}'

#check the value of key “data:1”
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["Query","data:1"]}'



#ERROR CASE consumidor invoke CreateCar().
#CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/users/Admin@consumidor.acme.com/msp  CORE_PEER_ADDRESS=peer0.consumidor.acme.com:7051 CORE_PEER_LOCALMSPID="consumidorMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/peers/peer0.consumidor.acme.com/tls/ca.crt  peer chaincode invoke -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA -C  $CHANNEL_NAME  -n $CHAINCODE_NAME -c '{"Args":["Set","did:4","marianela","avacado"]}'