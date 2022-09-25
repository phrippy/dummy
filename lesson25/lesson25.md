Создать мультистейдж Докер имедж с копированием артефакта между стейджами (докеризировать приложение), ARG и ENV, а также exec ENTRYPOINT и дефолтными аргументами в CMD.

ARG & ENV должны быть объявлены но не обязательно использованы.

можно использовать следующий проект:

https://github.com/agoncal/agoncal-application-petstore-ee7

`sudo apt install maven openjdk-17-jdk`

```Dockerfile
FROM maven as builder

WORKDIR /src

RUN git clone https://github.com/agoncal/agoncal-application-petstore-ee7.git .

RUN mvn clean compile -Dmaven.test.skip=true
RUN mvn clean package -Dmaven.test.skip=true


FROM adoptopenjdk/openjdk11

WORKDIR /app

COPY --from=builder /src/target/applicationPetstore.war .

ENTRYPOINT ["java", "-jar", "/app/applicationPetstore.war"]
```


