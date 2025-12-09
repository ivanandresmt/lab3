# 1. Dockerfile
FROM node:18-alpine

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código
COPY . .

# Exponer el puerto (ajusta si la app usa otro, ej: 3000 u 8080)
EXPOSE 3000

# Comando de inicio
CMD ["npm", "start"]