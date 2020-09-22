El objetivo de este proyecto es, siguiendo el curso de hyperledger replicar una red en hyperledger y ampliar este, tratando de conectarlo con la red de stellar para realizar pagos. deseenme suerte :)

En este caso va a haber tres clases de participantes en nuestra red:
        Productores:
            son los que producen,
            estan conectados en dos canales diferentes:
                el primer canal privado sera con los Mayoristas para crear ofertas personalizadas.
                el segundo canal privado sera con los consumidores finales y los mayoristas.
        Consumidores finales:
            son los usuarios finales del marketplace,
            estan conectados con los productores por un canal y con los mayoristas.
            esto permite que los consumidores puedan acceder a los productos tanto por parte de los mayoristas como de los productores
        Mayoristas:
            son los que se encargan de comprar a gran escala y vender a pequeña.
                Estan conectados con los consumidores finales para venderles los productos y con los productores  en un mismo canal para que tengan libertad de mercado sin abusos.
                Estan conectados con los productores por un canal privado para recibir mejores ofertas por compras a gran escala.

el primer paso es crear el crypto-config.yaml el cual nos permitira crear los certificados seguros para cada una de las organizaciones.