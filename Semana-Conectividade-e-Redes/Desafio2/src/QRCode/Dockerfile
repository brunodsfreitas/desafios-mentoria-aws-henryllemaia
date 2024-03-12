# Use uma imagem base Node.js
FROM node:alpine

# Crie o diretório de trabalho
WORKDIR /app

# Copie os arquivos necessários para o contêiner
COPY package.json .
COPY index.js .

# Instale as dependências
RUN npm install

# Exponha a porta 3000 para acessar a página da web
EXPOSE 3000

# Comando para iniciar o servidor web
CMD ["npm", "start"]
