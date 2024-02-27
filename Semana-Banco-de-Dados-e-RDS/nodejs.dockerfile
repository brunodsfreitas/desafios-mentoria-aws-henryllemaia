# Use a imagem oficial do Node.js como base
FROM node:14

# Crie e defina o diretório de trabalho dentro do contêiner
WORKDIR /usr/src/app

# Copie o arquivo package.json e o arquivo package-lock.json (se existir)
COPY package.json ./

# Instale as dependências do aplicativo
RUN npm install

# Copie o restante do código-fonte do aplicativo
COPY ./index.html .
COPY ./app.js .

# Exponha a porta em que a aplicação estará em execução
EXPOSE 3000

# Comando para iniciar a aplicação quando o contêiner for iniciado
CMD ["node", "app.js"]