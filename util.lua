---Módulo de funções de uso geral v1.1
--@author Manoel Campos da Silva Filho
--<a href="http://manoelcampos.com">http://manoelcampos.com</a>

local _G, io, print, string, coroutine, canvas, tonumber, pairs, type = 
      _G, io, print, string, coroutine, canvas, tonumber, pairs, type

module "util"


---Imprime uma tabela, de forma recursiva
--@param tb A tabela a ser impressa
--@param level Apenas usado internamente para 
--imprimir espaços para representar os níveis
--dentro da tabela.
function printable(tb, level)
  level = level or 1
  local spaces = string.rep(' ', level*2)
  for k,v in pairs(tb) do
      if type(v) ~= "table" then
         print(spaces .. k..'='..v)
      else
         print(spaces .. k)
         level = level + 1
         printable(v, level)
      end
  end  
end

---Quebra uma string para que a mesma tenha linhas
--com um comprimento máximo definido, não quebrando
--a mesma no meio das palavras.
--@param Text String a ser quebrada
--@param maxLineSize Quantidade máxima de caracteres por linha
--@return Retorna uma tabela onde cada item é uma linha
--da string quebrada.
function breakString(text, maxLineSize)
  local t = {}
  local str = text
  local i, fim, countLns = 1, 0, 0

  if (str == nil) or (str == "") then
     return t
  end 

  str = string.gsub(str, "\n", " ")
  str = string.gsub(str, "\r", " ")
    
  while i <= #str do
     countLns = countLns + 1
     if i > #str then
        t[countLns] = str
     else
        fim = i+maxLineSize-1
        if fim > #str then
           fim = #str
        else
	        --se o caracter onde a string deve ser quebrada
	        --não for um espaço, procura o próximo espaço
	        if string.byte(str, fim) ~= 32 then
	           fim = string.find(str, ' ', fim)
	           if fim == nil then
	              fim = #str
	           end
	        end
        end
        t[countLns]=string.sub(str, i, fim)
        i=fim+1
     end
  end
  
  return t
end


---Imprime um texto na tela, quebrando o mesmo nos limites
--horizontais da área do canvas.
--@param areaWidth Largura a área disponível para impressão
--@parma x Posição x onde o texto deve ser impresso
--@param initialY Posição y inicial a ser impresso o texto
--@param text Texto a ser impresso, sendo quebrado em
--linhas para caber horizontalmente na largura
--definida para impressão
function paintBreakedString(areaWidth, x, initialY, text)
     --Text Width e Text Height de um caractere minúsculo
     local tw, th = canvas:measureText("a")
     
     --Estima quantos caracteres cabem dentro da largura
     --definida para a exibição de uma mensagem do Twitter 
     local charsByLine = tonumber(string.format("%d", areaWidth / tw))
     
     --Quebra o texto em diversas linhas, 
     --gerando uma tabela onde cada item é uma linha que
     --foi quebrada. Isto é usado para que o texto seja
     --exibido sem sair da tela. 
     local textTable = breakString(text, charsByLine)
     local y = initialY
     --Percorre a tabela gerada a partir da quebra do texto 
     --em linhas, e imprime cada linha na tela 
     for k,ln in pairs(textTable) do
         canvas:drawText(x, y, ln)
         y = y + th
         print("---------------------"..ln)
     end
end

---Desenha um texto na tela
--@param x Posição horizontal a ser impresso o texto
--@param y Posição vertical a ser impresso o texto
--@param text texto a ser desenhado
--@param fontName Nome da fonte a ser utilizada para imprimir o texto. Opcional
--@param fontSize Tamanho da fonte. Opcional
--@param fontColor Cor da fonte. Opcional
function paintText(x, y, text, fontName, fontSize, fontColor)
     if fontName and fontSize then
        canvas:attrFont(fontName, fontSize)
     end
     if fontColor then
        canvas:attrColor(fontColor)
     end
     
     --width e height do canvas
     local cw, ch = canvas:attrSize()
     canvas:drawText(x, y, text)     
end

function fileExists(fileName)
  local file = io.open(fileName)
  if file then
    io.close(file)
    return true
  else
    return false
  end
end


---Cria um arquivo com o conteúdo informado em text.
--Se o arquivo já existir, substitui.
--@param content Conteúdo a ser adicionado no arquivo
--@param fileName Nome do arquivo a ser gerado.
--@return Retorna true caso o arquivo seja salvo com sucesso.
function createFile(content, fileName, binaryFile)
    binaryFile = binaryFile or false
    local mode = ""
    if binaryFile then
       mode = "w+b"
    else
       mode = "w+"
    end
    file, err = io.open(fileName, mode)
    if file == nil then
    	print("Erro ao abrir arquivo "..fileName.."\n".. err)
    	return false
    else
    	print("Arquivo", fileName, "criado com sucesso")
        file:write(content)
        file:close()
        return true
    end
end

---Função para converter uma tabela para o formato URL-Encode,
--também chamado de Percent Encode, segundo RFC 3986.
--Fonte: http://www.lua.org/pil/20.3.html. Gerada a partir das funções
--escape e encode, gerando uma só.
--@param t Tabela contendo os pares param=value
--que representam os parâmetros a serem codificados para o formato URL-Encode,
--ou String contendo o texto a ser codificado.
--@return Retorna uma string codificada em URL-Encode
function urlEncode(t)
	  local function escape (s)
	    s = string.gsub(s, "([&=+%c])", function (c)
	          return string.format("%%%02X", string.byte(c))
	        end)
	    s = string.gsub(s, " ", "+")
 	    return s
 	  end

      if type(t) == "string" then
         return escape(t)
      else
	     local s = ""
	     for k,v in pairs(t) do
	       s = s .. "&" .. escape(k) .. "=" .. escape(v)
	     end
	     return string.sub(s, 2)     -- remove first `&'
      end
end    

---Cria uma co-rotina para execução de uma determinada função.
--@param f Função body a ser executada pela co-rotina
--@param ... Parâmetros adicionais que serão passados à função
--body da co-rotina, passada no parâmetro f.
function coroutineCreate(f, ...)
    coroutine.resume(coroutine.create(f), ...)
end
