# Modelo de Prompt para Resumo de Transcrições

Resume esta transcrição intitulada: [TITLE]

IDIOMA:
- Escreve toda a análise em português europeu (Portugal), independentemente do idioma da transcrição. Usa a ortografia e o vocabulário de Portugal (por exemplo, "ficheiro", "ecrã", "utilizador"), não do Brasil.
- Mantém em itálico, na língua original, citações curtas ou termos que percam significado quando traduzidos, acrescentando a tradução entre parênteses quando for útil.
- Os títulos das secções devem ser exatamente os indicados abaixo, em português.

- Analisa esta transcrição baseando-te apenas no seu conteúdo. Não incorpores conhecimento prévio sobre o canal, o orador ou as posições que costuma defender.
- Se a terminologia de uma área específica precisar de explicação, define-a com base no contexto da própria transcrição.

REQUISITOS DE LEITURA DO CONTEÚDO:
- Antes de escreveres qualquer resumo, lê a transcrição INTEIRA com a ferramenta `Read`.
- Se a transcrição for grande, usa os parâmetros `offset` e `limit` da ferramenta `Read` para obter o resto do conteúdo por partes.
- Continua até teres lido todas as linhas. Não comeces a resumir antes de teres lido o texto completo.

FORMATO DA TRANSCRIÇÃO:
- A transcrição está no formato WebVTT (.vtt), que inclui timestamps para cada segmento.
- Usa estes timestamps para ancorar a análise em momentos específicos do vídeo.
- Ao citar timestamps, usa o formato `[HH:MM:SS]` (resolução ao segundo, sem frações). Para intervalos, usa `[HH:MM:SS--HH:MM:SS]`, com dois hífenes (`--`) como separador e não um travessão.
- Quando um conceito, afirmação ou falácia se estende por vários segmentos consecutivos, cita o intervalo completo da passagem relevante.
- Nos títulos markdown (`#`, `##`, `###`), os timestamps aparecem sem acentos graves. Em todo o restante texto (listas, prosa), envolve cada timestamp em acentos graves para facilitar a leitura.

**FORMATO DE SAÍDA:**
Mantém um tom neutro e descritivo; não apoies nem critiques as opiniões do orador.
Apresenta um resumo estruturado com as seguintes secções:

## Visão Geral
Um resumo de alto nível, com 3 a 5 frases, da tese e do âmbito do vídeo.

## Material de Origem
- **Fonte:** [SOURCE]

Regras de formatação desta secção:
- Se a fonte for um URL, apresenta-o como ligação markdown: `[URL](URL)` (o texto da ligação e o endereço são iguais).
- Se a fonte for um caminho de ficheiro local, apresenta-o como código inline: `` `ficheiro` ``.
- Usa sempre exatamente um ponto de lista com a etiqueta em negrito **Fonte:** seguida do valor.
- Não acrescentes comentários, descrições ou metadados a esta secção.

## Termos e Conceitos-Chave
Uma lista dos termos, conceitos ou quadros de referência importantes introduzidos pelo orador, cada um com uma definição ou explicação baseada no que o orador disse ou no que se pode inferir diretamente do contexto. Inclui o timestamp da primeira menção. Usa o formato:
- **Termo** `[HH:MM:SS]`: Definição

## Resumo Detalhado
Um resumo completo, secção a secção, do conteúdo, com subtítulos para organizar os temas principais ou as mudanças na discussão. Inclui um intervalo de timestamps em cada subtítulo, indicando a duração dessa secção. Privilegia a exaustividade em vez da brevidade. Usa o formato:
### Título da Secção [HH:MM:SS--HH:MM:SS]

## Referências Bíblicas
(Inclui esta secção apenas se o conteúdo for teológico)
Lista todos os versículos ou passagens da Bíblia mencionados, com um breve contexto sobre a forma como o orador os usou. Inclui todos os timestamps em que cada versículo é referido (não apenas a primeira menção), porque é comum um orador introduzir um versículo num contexto e voltar a ele mais tarde. Usa o formato:
- **Versículo** `[HH:MM:SS]`, `[HH:MM:SS]`, ...: Contexto em que o orador o usou.

## Notas sobre as Provas
Assinala as afirmações relevantes e classifica o tipo de fundamentação que o orador apresenta. Inclui um timestamp ou intervalo que indique onde aparecem a afirmação e as respetivas provas. Uma afirmação e as suas provas podem estender-se por vários segmentos; cita o intervalo completo. Usa o formato:
- **Categoria** `[HH:MM:SS--HH:MM:SS]`: Descrição da afirmação e das provas.

Categorias:
- **Anedótica**: Experiência ou observação pessoal ("Na minha experiência...")
- **Apelo à autoridade**: Refere a opinião de outra pessoa sem uma fonte direta ("O DHH acha que...")
- **Argumento lógico**: Raciocínio fundamentado sem dados externos
- **Fonte citada**: Estudo, artigo, dado ou referência concreta e verificável

## Falácias Lógicas
Identifica as falácias lógicas presentes no raciocínio do orador. Se não encontrares nenhuma, escreve "Não foram detetadas falácias lógicas significativas."
**IMPORTANTE:** Assinala apenas as falácias que enfraquecem significativamente o argumento; recursos retóricos não são necessariamente falácias.

Para cada falácia encontrada, inclui um timestamp ou intervalo que abranja a passagem relevante (da premissa à conclusão). Uma falácia pode envolver uma premissa enunciada num momento e uma conclusão tirada mais tarde; cita o intervalo completo. Usa o formato:
- **Tipo de falácia** `[HH:MM:SS--HH:MM:SS]`: Breve descrição de onde e como aparece no argumento e porque enfraquece o raciocínio.

Falácias comuns a ter em atenção:
- Ad Hominem (atacar a pessoa em vez do argumento)
- Espantalho (deturpar uma posição contrária para a tornar mais fácil de atacar)
- Falso Dilema (apresentar apenas duas opções quando existem mais)
- Apelo à Emoção (recorrer a sentimentos em vez da lógica)
- Whataboutism/Tu Quoque (desviar a crítica apontando o comportamento de outros)
- Bola de Neve / Declive Escorregadio (assumir que uma coisa levará inevitavelmente a consequências extremas)
- Generalização Precipitada (tirar conclusões gerais a partir de poucos exemplos)
- Falsa Autoridade (citar fontes sem qualificação como se fossem especialistas)

## Questões e Pontos Pouco Desenvolvidos
Lista os pontos que pareceram ambíguos, pouco desenvolvidos ou que merecem ser aprofundados. Inclui um timestamp ou intervalo que indique onde ocorre a ambiguidade ou lacuna. Indica explicitamente quando uma interpretação é incerta.
