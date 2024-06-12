---http v0.9.4: Biblioteca para envio e recebimento de requisições HTTP,
--possibilitando também, o download de arquivos por meio
--de tal protocolo.<br/>
--Utiliza a classe tcp disponibilizada em 
-- <a href="http://www.telemidia.puc-rio.br/~francisco/nclua/tutorial/index.html">http://www.telemidia.puc-rio.br/~francisco/nclua/tutorial/index.html</a>
-- e o módulo de conversão de/para base64 disponível em <a href="http://lua-users.org/wiki/BaseSixtyFour">http://lua-users.org/wiki/BaseSixtyFour</a><p/>
--Licença: <a href="http://creativecommons.org/licenses/by-nc-sa/2.5/br/">http://creativecommons.org/licenses/by-nc-sa/2.5/br/</a>
--@author Manoel Campos da Silva Filho 
--Professor do Instituto Federal de Educação, Ciência e Tecnologia do Tocantins<br/>
--Mestrando em Engenharia Elétrica na Universidade de Brasília, na área de TV Digital<br/>
--<a href="http://manoelcampos.com">http://manoelcampos.com</a>
---<p/>
---<h3>TODAS AS FUNÇÕES EXISTENTES NESTE MÓDULO DEVEM  SER EXECUTADAS DENTRO DE UMA CO-ROTINA.</h3> 
--Pode-se utilizar a função util.coroutineCreate
--para criar a co-rotina para executar a função desejada.<p/>
--As funções da classe TCP,
--devido usarem co-rotinas para simular threads
--e enviar requisições HTTP, a chamada
--da função tcp.execute retorna imediatamente, não aguardando
--a resposta da requisição HTTP enviada. Assim, para resolver
--este problema, utiliza-se o recurso de funções de callback.
--Estas são funções que são passadas por parâmetro para outra função,
--e só são executadas depois que determinado evento ocorra,
--neste caso, após ser obtida resposta da requisição TCP enviada.
--Por enquanto, essa foi a única forma de encapsular
--todo o código, necessário para envio de uma requisição HTTP,
--em uma função única.<p/>
--Segue abaixo, exemplo de utilização de uma das funções deste módulo.<p/>
-- -----------------------------------------------------------------------------------<br/><br/>
-- local fileName = "image.jpg"<br/><br/>
-- ---Função de callback a ser<br/>
-- --executada quando a imagem for obtida do servidor,<br/>
-- --para exibir a mesma na tela.<br/>
-- local function showImageCallback()<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;local img = canvas:new(fileName)<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;canvas:compose(1, 1, img)<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;canvas:flush()<br/>
-- end<br/><br/>
-- ---Envia uma requisição HTTP para baixar uma imagem de um servidor web<br/>
-- --&#64;param imageUrl URL da imagem a ser baixada<br/>
-- local function getImage(imageUrl)<br/>
-- &nbsp;&nbsp;if http.getFile(imageUrl, fileName) then<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;--Após baixar a imagem, chama a função de callback p/ exibir a mesma<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;showImageCallback()<br/>
-- &nbsp;&nbsp;end <br/>
-- end<br/><br/>
-- --Cria uma co-rotina para executar a função getImage, definida acima.<br/>
-- --Com getImage sendo chamada dentro de uma co-rotina, ela espera<br/>
-- --até o download da imagem ser concluído, para então exibir a mesma.<br/>
-- --A url passada a util.coroutineCreate é repassada a getImage,<br/>
-- --no momento da chamada de desta função, feita dentro de util.coroutineCreate.<br/>
-- util.coroutineCreate(getImage, "http://manoelcampos.com/arquivos/twitter1.png")<p/>
-- ---------------------OUTRO EXEMPLO DE UTILIZAÇÃO-----------------------------------<br/><br/>
-- ---Função de callback a ser<br/>
-- --executada quando a resposta da requisição http for obtida, <br/>
-- --imprimindo a resposta no terminal.<br/>
-- local function printResponse(response)<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;print(response)<br/>
-- end<br/><br/>
-- ---Envia uma requisição HTTP para um servidor web<br/>
-- --&#64;param url URL da página a ser acessada no servidor web<br/>
-- local function sendRequest(url)<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;local response = http.request(url, "GET")<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;--Após receber a resposta da requisição http, chama a função de callback p/ imprimir o resultado<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;if response then<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;printResponse(response)<br/>
-- &nbsp;&nbsp;&nbsp;&nbsp;end<br/>
-- end<br/><br/>
-- --Cria uma co-rotina para executar a função sendRequest, definida acima.<br/>
-- --Com sendRequest sendo chamada dentro de uma co-rotina, ela espera<br/>
-- --até a resposta da requisição ser obtida, para então imprimir o resultado.<br/>
-- --A url passada a util.coroutineCreate é repassada a sendRequest,<br/>
-- --no momento da chamada de desta função, feita dentro de util.coroutineCreate.<br/>
-- util.coroutineCreate(sendRequest, "http://rastreador.manoelcampos.com/index.php")<br/>


require "tcp"
require "base64"
require "util"

local _G, tcp, print, util, base64, string, coroutine, table, type = 
      _G, tcp, print, util, base64, string, coroutine, table, type

module "http"

---Envia uma requisição HTTP para um determinado servidor
--@param url URL para a página que deseja-se acessar
--@param method Método HTTP a ser usado: GET ou POST. Se omitido, é usado GET.
--onde a requisição deve ser enviada
--@param userAgent Nome da aplicação/versão que está enviando a requisição. Opcional
--@param headers Headers HTTP adicionais a serem incluídos na requisição. Opcional
--@param body String com o conteúdo a ser adicionado à requisição, já
--no formato URL-Encode, ou uma tabela, contendo pares de paramName=value,
--representando parâmetros a serem enviados. Opcional.
--Deve estar no formato URL Encode. Opcional
--@param user Usuário para autenticação básica. Opcional
--@param password Senha para autenticação básição. Opcional
--@return Retorna a resposta da requisição HTTP
function request(url, method, userAgent, headers, body, user, password)
    if method == nil or method == "" then
       method = "GET"
    end
    method = string.upper(method)
    if method ~= "GET" and method ~= "POST" then
       error("Parâmetro method deve ser GET ou POST")
    end
    
    local co = false
    local protocol, host, urn = splitUrl(url)
    if protocol == nil or protocol == "" then
       protocol = "http://"
       url = protocol .. url
    end
    
    function f()
	    tcp.execute(
	        function ()
	            tcp.connect(host, 80)
	            --conecta no servidor
	            print("Conectado a "..host)
	            
				--Troca espaços na URL por %20
	            url = string.gsub(url, " ", "%%20")
	            local request = {}
	            table.insert(request, method .." "..url.." HTTP/1.0")
	            
	            if userAgent and userAgent ~= "" then
	               table.insert(request, "User-Agent: " .. userAgent)
	            end      
	            if headers and headers ~= "" then
	               table.insert(request, headers)
	            end   
	            --O uso de Host na requisição é necessário
	            --para tratar redirecionamentos informados 
	            --pelo servidor (código HTTP como 301 e 302)
	            table.insert(request, "Host: "..host)
	            if user and password and user ~= "" and password ~= "" then
	               table.insert(request, "Authorization: Basic " .. 
	                     base64.enc(user..":"..password))
	            end
                if body and body ~= "" then
                   if type(body) == "table" then
                      body = util.urlEncode(body)
                   end
                   --length of the URL-encoded body data
                   table.insert(request, "Content-Length: " .. #body.."\n")
                   table.insert(request, body)
                end   	            
				table.insert(request, "\n")
				local requestStr = table.concat(request, "\n")
	            print("request: "..requestStr)
	            --envia uma requisição HTTP para obter o arquivo XML do feed RSS
	            tcp.send(requestStr)
	                       	
	           	--obtém todo o conteúdo do arquivo XML solicitado
	            local response = tcp.receive("*a")
	            if response == nil then
	            	print("Erro ao receber dados da conexao TCP")
		        end
		          
	            tcp.disconnect()
			    print("\n--------------------------Desconectou")
	    		coroutine.resume(co, response)        
	        end
	    )    
	    print("\n--------------------------Saiu da body function")
    end
    
    print("\n--------------------------Iniciar co-rotina (resume)")
    coroutine.resume(coroutine.create(f))
    print("\n--------------------------Terminou resume")
    co = coroutine.running()
    print("\n--------------------------Co-rotina suspensa (yield)")
    local response =  coroutine.yield()
    print("\n--------------------------Co-rotina finalizada (terminou yield)")
    return response
end

---Baixa um arquivo xml a partir de um servidor web.
--@param url URL para a página que deseja-se acessar
--@param method Método HTTP a ser usado: GET ou POST. Se omitido, é usado GET.
--onde a requisição deve ser enviada
--@param userAgent Nome da aplicação/versão que está enviando a requisição. Opcional
--@param headers Headers HTTP adicionais a serem incluídos na requisição. Opcional
--@param body String com o conteúdo a ser adicionado à requisição. 
--Deve estar no formato URL Encode. Opcional
--@param user Usuário para autenticação básica. Opcional
--@param password Senha para autenticação básição. Opcional
--@return Em caso de erro: retorna nil. 
--Em caso de sucesso, retorna uma string contendo o código XML.
function getXml(url, method, userAgent, headers, body, user, password)
    --(url, method, userAgent, headers, body, user, password)
    local response = request(url, method, userAgent, headers, body, user, password)
    if response then
        print("Dados da conexao TCP recebidos")
        print(response)
        --Como a resposta da requisição será um arquivo XML,
        --e essa resposta conterá um cabeçalho HTTP,
        --é preciso remover esse cabeçalho e salvar
        --apenas o conteúdo XML válido. Este inicia em um sinal <
        local i = string.find(response, "?xml version=")
        if i then
           --Remove o cabeçalho HTTP da resposta,
           --deixando somente o código XML
           response = string.sub(response, i-1, #response)
           
           --Apenas para depuração
           util.createFile(response, "response.xml")
        else
           print("O marcador de início do XML (<) não foi encontrado")
           response = nil
        end
    end
    return response
end

---Envia uma requisição HTTP para uma URL que represente um arquivo,
--e então faz o download do mesmo.
--@param url URL para onde enviar a requisição
--@param fileName Caminho completo para salvar o arquivo localmente
--@param userAgent Nome/versão do cliente http. Opcional
--@param user Usuário para autenticação básica. Opcional
--@param password Senha para autenticação básição. Opcional
--@return Retorna true em caso de sucesso, e false em caso de erro.
function getFile(url, fileName, userAgent, user, password)
    --(url, method, userAgent, headers, body, user, password)
    local response = request(url, "GET", userAgent, nil, nil, user, password)

    if response then
       --print(response, "\n")
       print("Dados da conexao TCP recebidos")
       --Verifica se o código de retorno é OK
       if string.find(response, "200 OK") then
          --O corpo da mensagem, que contém o arquivo
          --a ser baixado, inicia após duas quebras
          --de linha (cada quebra de linha 
          --possui dois caracteres: \r\n)
          local i = string.find(response, "\r\n\r\n")
          --A adição de 4 na posição i é usado para
          --pular as duas quebras de linha (cada quebra
          --possui dois caracteres: \r\n) e obter
          --o conteúdo do arquivo, que está após elas
          response = string.sub(response, i+4, #response)
          util.createFile(response, fileName, true)
          --local contentLength = getHttpHeader(response, "Content-Length")
          return true
       end
       return false
    else
       print("Erro ao receber dados da conexao TCP")
       return false
    end
end

---Obtem o valor de um determinado campo de uma resposta HTTP
--@param response Conteúdo da resposta HTTP de onde deseja-se extrair
--o valor de um campo do cabeçalho
--@param fieldName Nome do campo no cabeçalho HTTP
function getHttpHeader(response, fieldName)
  --Procura a posição de início do campo
  local i = string.find(response, fieldName .. ":")
  --Se o campo existe
  if i then
     --procura onde o campo termina (pode terminar com \n ou espaço
     --a busca é feita a partir da posição onde o campo começa
     local fim = string.find(response, "\n", i) or string.find(response, " ", i)
     return string.sub(response, i, fim)
  else
     return nil
  end
end

---Obtem uma URL e divide a mesma em protocolo, host e URN
--@param url URL a ser dividida
--@return Retorna o protocolo, host e a URN obtidas da URL
function splitUrl(url)
  --TODO: O uso de expressões regulares seria ideal nesta função
  --por meio de string.gsub

  --procura onde inicia o nome do servidor, que é depois
  --do :// que representa o protocolo utilizado na URL
  local i = string.find(url, "://")
  local protocolo = false
  if i == nil then 
     protocolo = nil
  else
     protocolo = string.sub(url, 1, i+2)
  end
  --se a URL não possui um protocolo, então o nome
  --do servidor inicia na primeira posição
  if i == nil then
     i = 1 
  else
	 --soma 3 em i para pular o ://, que identifica o protocolo,
	 --e iniciar na primeira posição do nome do host
	 i=i+3
  end

  --procura onde termina o nome do servidor, 
  --na primeira barra após o ://
  local j = string.find(url, "/", i)
  
  local host = string.sub(url, i, j-1)
  local urn  = string.sub(url, j, #url)
  return protocolo, host, urn
end
