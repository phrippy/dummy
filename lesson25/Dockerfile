FROM maven:3.8.5-ibmjava-alpine as builder

WORKDIR /src

RUN apk update && apk --no-cache add git
RUN git clone https://github.com/agoncal/agoncal-application-petstore-ee7.git .

RUN mvn clean compile
#RUN mvn clean package
RUN mvn clean package -Dmaven.test.skip=true


FROM openjdk

WORKDIR /app

ENV FILENAME=applicationPetstore.war

COPY --from=builder /src/target/$FILENAME .

RUN echo "java -jar $FILENAME" > script.sh && chmod +x script.sh

ENTRYPOINT ["bash", "script.sh"]
