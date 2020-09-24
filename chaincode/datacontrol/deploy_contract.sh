#!bin/sh

export CHANNEL_NAME=marketplace
export CHAINCODE_NAME=datacontrol
export CHAINCODE_VERSION=1
export CC_RUNTIME_LANGUAGE=golang
export CC_SRC_PATH="/opt/gopath/src/github.com/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem


#Descarga dependencias
#export FABRIC_CFG_PATH=$PWD/configtx
#pushd ../chaincode/$CHAINCODE_NAME
#GO111MODULE=on go mod vendor
#popd
# hash= 3853864508f04779c3a63e60e9b0d10a0864e48060498996d1a5e7f36035caf3



#Empaqueta el chaincode
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

#peer lifecycle chaincode install example
#first peer peer0.productor.acme.com
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz 

#Actualizar este  valor con el que obtengan al empaquetar el chaincode: 
export CC_PACKAGEID=d5155c929c86e7a1d76d30abbe3f27a31a5d3e278344b9cfce5175a3db6f654b

# peer0.consumidor
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/users/Admin@consumidor.acme.com/msp CORE_PEER_ADDRESS=peer0.consumidor.acme.com:7051 CORE_PEER_LOCALMSPID="consumidorMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumidor.acme.com/peers/peer0.consumidor.acme.com/tls/ca.crt peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz

# peer0.mayorista
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/users/Admin@mayorista.acme.com/msp CORE_PEER_ADDRESS=peer0.mayorista.acme.com:7051 CORE_PEER_LOCALMSPID="mayoristaMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz



#Endorsement policy for lifecycle chaincode 

peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --package-id datacontrol_1:$CC_PACKAGEID

#Commit  the chaincode  for productor
 peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --output json
 
 
 #commit chaincode FAILURE
#peer lifecycle chaincode commit -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA  --peerAddresses peer0.productor.acme.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/productor.acme.com/peers/peer0.productor.acme.com/tls/ca.crt --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')"

#2020-09-03 17:39:05.756 UTC [chaincodeCmd] ClientWait -> INFO 046 txid [453ed408b77c198d7159904c94b8d44b4d7633273f200bafc87c5419901883c2] committed with status (ENDORSEMENT_POLICY_FAILURE) at peer0.productor.acme.com:7051
#Error: transaction invalidated with status (ENDORSEMENT_POLICY_FAILURE)



#Let mayorista approve the chaincode package.
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/users/Admin@mayorista.acme.com/msp  CORE_PEER_ADDRESS=peer0.mayorista.acme.com:7051  CORE_PEER_LOCALMSPID="mayoristaMSP"  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt  peer lifecycle chaincode approveformyorg --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --package-id datacontrol_1:$CC_PACKAGEID


#check the chaincode commit 
 peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')" --output json
 
 #commit chaincode SUCCESS
 #Now commit chaincode. Note that we need to specify peerAddresses of both productor and mayorista (and their CA as TLS is enabled).
peer lifecycle chaincode commit -o orderer.acme.com:7050 --tls --cafile $ORDERER_CA --peerAddresses peer0.productor.acme.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/productor.acme.com/peers/peer0.productor.acme.com/tls/ca.crt --peerAddresses peer0.mayorista.acme.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mayorista.acme.com/peers/peer0.mayorista.acme.com/tls/ca.crt --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('productorMSP.peer','mayoristaMSP.peer')"

#check the status of chaincode commit
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --output json
