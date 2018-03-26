#!/bin/bash

# Iniciacao de variaveis
invalidos=0; # votos inválidos
opt=0; # variavel para gerenciar as opcoes dos menus
qtdCand=0; # variavel referente a quantidade de candidatos registrados
voto=0; # variavel de controle para adicionar os votos
valid=0; # variavel de controle para validar o voto ou nao

# Funcao referente a tela para cadastrar um candidato
function CadastroCand {
 clear
 opt=0;
 echo "----------------------------"
 echo "1- Cadastrar"
 echo "2- Limpar Cadastros"
 echo "3- Voltar"
 echo "----------------------------"
 while [ $opt -ne 1 ] && [ $opt -ne 2 ] && [ $opt -ne 3 ]; # Laço para verificar a opcao selecionada pelo usuario
 do
  read opt # Le a opcao digitada
  if [ $opt -eq 1 ]; then # Se a opcao for igual a 1, chama a funcao CadastrarCandidato
   CadastrarCandidato
  elif [ $opt -eq 2 ]; then # Se for igual a 2, limpa os cadastros ja realizados e volta na mesma funcao
   > candidatos.txt
   CadastroCand
  elif [ $opt -eq 3 ]; then # Se for igual a 3, voltara para a tela inicial
   Inicio
  fi
 done

}
# Funcao referente a tela de cadastro de candidatos
function CadastrarCandidato {
 clear
 echo "-------------------------------------------------------"
 echo " Digite o candidato e depois seu numero de votacao"
 echo " * Digite 0 para encerrar o cadastro"
 echo "-------------------------------------------------------"
 read cad # Le o nome do candidato
 echo 
 echo "Digite o numero de votacao do candidato: $cad"
 read num # Le o numero referente ao voto do candidato

 while [ $cad != 0 ] # Inicia um loop verificando se o valor da variavel do candidato for 0, se for, termina o cadastro
 do
  echo "$num $cad" >> candidatos.txt # Insere o numero e o nome do candidato no arquivo candidatos.txt
  echo
  # Repete o processo acima
  echo "Digite o nome do novo candidato:"
  read cad
  echo 
  echo "Digite o numero para o candidato: $cad"
  read num
 done
 Inicio # Apos terminar, voltar a tela inicial
}
# Funcao para iniciar a votacao
function IniciarVotacao {
 clear

 while read LINHA; do # Le todas as linhas do arquivo candidatos.txt

  NOME+=([$qtdCand]=$(echo $LINHA | awk '{print $2}')) # Salva o nome dos candidatos em uma variavel do tipo vetor
  NUMERO+=([$qtdCand]=$(echo $LINHA | awk '{print $1}')) # Salva o numero dos candidatos em uma variavel do tipo vetor
  VOTOS+=([$qtdCand]=0) # Inicializa a variavel de votos referente a o indice de cada candidato
  let "qtdCand++"

 done < candidatos.txt
 votoinfo # Executa a funcao para informar o usuario
 read voto # Le o voto inserido pelo usuario
 valid=0; # Variavel logica para validacao do voto
 while [ $voto -ne 0 ]; do # Se o valor da variavel de voto for diferente de 0, continua executando o laço de votacao
  for(( n=0; n < $qtdCand; n++)); do # Verificar o voto para cada candidato
     if [ $voto -eq $((${NUMERO[$n]})) ]; then # Se bater com o numero de votacao do candidato
       newVal=$((${VOTOS[$n]} + 1)) # Adiciona +1 voto para o candidato selecionado
       VOTOS[$n]=$newVal # Insere no vetor de votos o valor do voto
       valid=1; # Variavel logica para indicar se o voto foi concluido ou nao
       votoinfo # Atualiza a tela informativa do usuario
     fi # Termina a condiçao
  done # Termina o laço
  if [ $valid -eq 0 ]; then # Se o voto nao for valido, referindo-se a variavel logica criada
   let invalidos++ # Adiciona mais um para os votos invalidos
   votoinfo # Atualiza a tela do usuario
  fi
  valid=0;
  read voto # Repete o processo
 done
 calculoTotal # Chama a funcao para calcular os valores
}
# Funcao para calcular as porcentagens e o total de votos
function calculoTotal {
 for(( n=0; n < $qtdCand; n++)); do # Laço para a quantidade de candidatos existentes
  total=$((total + ${VOTOS[$n]})) # Faz a soma do total de votos
 done # Termina o laço
 total=$(($total + $invalidos)) # Soma os votos invalidos ao total
 if [ $total -ne 0 ]; then # Se o total for diferente de 0, faz o calculo
  echo "-------------- RESULTADO -----------------" 	
  echo " NOME DO CANDIDATO | VOTOS | PORCENTAGEM"
  echo "------------------------------------------"
  for(( s=0; s < $qtdCand; s++ )); do # Laço para a quantidade de candidatos existentes
   porc=$(echo "scale=1; ${VOTOS[$s]} / $total * 100" | bc) # Calcula a porcentagem de votos para cada candidato
   echo -e "${NOME[$s]}\t\t | ${VOTOS[$s]}\t | $porc"; # Mostra ao usuario a informaçao do nome do usuario, seus votos e a porcentagem dos mesmos
  done
  invs=$(echo "scale=1; $invalidos / $total * 100" | bc) # Calcula a porcentagem dos votos invalidos referentes ao total de votos
  echo -e "VOTOS INVALIDOS  | $invalidos\t | $invs"; # Mostra ao usuario a porcentagem e o total de votos invalidos
  echo "------------------------------------------"
 fi
}
# Tela informativa durante a votaçao
function votoinfo {
 clear
 echo "------------ CANDIDATOS -------------" 	
 echo " NUMERO | NOME DO CANDIDATO | VOTOS"
 echo "-------------------------------------"
 for indice in "${!NOME[@]}"; do # Para cada candidato mostre suas respectivas informacoes
   echo -e "* ${NUMERO[$indice]}\t | ${NOME[$indice]}\t    | ${VOTOS[$indice]}"
 done
 echo "-------------------------------------"
 echo "Digite o numero do candidato a ser votado (encerra a votacao por 0):"
}
# Tela inicial do programa
function Inicio {
 clear
 opt=0;
 echo "----------------------------"
 echo "1- Cadastro de candidatos"
 echo "2- Votar"
 echo "3- Sair"
 echo "----------------------------"

 while [ $opt -ne 1 ] && [ $opt -ne 2 ] && [ $opt -ne 3 ]; # Laço para verificar a opcao selecionada pelo usuario
 do
  read opt # Leia a opcao
  if [ $opt -eq 1 ]; then # Se ela for igual a 1, mostre a tela de cadastro de um candidato
   CadastroCand
  elif [ $opt -eq 2 ]; then # Se igual a 2, mostre a tela de votacao
   IniciarVotacao
  elif [ $opt -eq 3 ]; then # Se igual a 3, finaliza o programa
   exit 0
  fi
 done
 
}
Inicio # Inicio da aplicaçao, chama a funcao inicial	

