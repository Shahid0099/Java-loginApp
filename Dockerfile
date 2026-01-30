# ================= BUILD STAGE =================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests


# ================= RUNTIME STAGE =================
FROM tomcat:10.1-jdk17-temurin

# Remove default Tomcat apps (reduce size & memory)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR into Tomcat ROOT
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]

