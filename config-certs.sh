#!bin/sh

# generamos las keys para las organizaciones y usuarios definidas en el crypto-config.yaml
cryptogen generate  --config=./crypto-config.yaml --output="./crypto-config"

# generamos el bloque genesis de la red blockchain

configtxgen -profile ThreeOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

# creamos el canal de comunicacion que incunve a las tres organizaciones

configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID marketplace

# creamos el perfil para cada una de las organizaciones dentro del canal

# org1 = productor
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/productorMSPanchors.tx -channelID marketplace -asOrg productorMSP
# org2 = consumidor
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/consumidorMSPanchors.tx -channelID marketplace -asOrg consumidorMSP
# org3 = mayorista
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/mayoristaMSPanchors.tx -channelID marketplace -asOrg mayoristaMSP

# una vez hecho esto podemos proceder a correr el script para levantar la red donde haremos uso de los archivos generados.
