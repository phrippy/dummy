FROM maven:3.8.5-ibmjava-alpine as builder

WORKDIR /src

RUN apk update && apk --no-cache add git && \
git clone https://github.com/agoncal/agoncal-application-petstore-ee7.git . && \
mvn clean compile && \
#mvn clean package && \
mvn clean package
#mvn clean package -Dmaven.test.skip=true


FROM openjdk:19-jdk-alpine3.16

WORKDIR /app

ENV FILENAME=applicationPetstore.war

COPY --from=builder /src/target/$FILENAME .

RUN echo "java -jar $FILENAME" > run && chmod +x run

ENTRYPOINT ["sh"]
CMD ["run"]
