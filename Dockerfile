#base image with Maven and JDK 17
FROM maven:3.9.6-eclipse-temurin-17
#Set working directory inside the container
WORKDIR /app
#Copy the entire project to the working directory
COPY . .    
#Build the project and skip tests
RUN mvn clean package -DskipTests
#Expose port 8080 for the application
EXPOSE 8080
#Set the command to run the application
CMD ["java", "-jar", "target/*.jar"]