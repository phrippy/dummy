FROM maven:3.6.2-ibmjava-alpine as builder

WORKDIR /src

RUN apk update && apk add git
RUN git clone https://github.com/agoncal/agoncal-application-petstore-ee7.git .

RUN mvn clean compile
#RUN mvn clean package
RUN mvn clean package -Dmaven.test.skip=true


FROM openjdk

WORKDIR /app

COPY --from=builder /src/target/applicationPetstore.war .

#ENTRYPOINT ["java", "-jar", "/app/applicationPetstore.war"]
CMD java -jar /app/applicationPetstore.war
