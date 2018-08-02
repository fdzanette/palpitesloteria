require 'nokogiri'
require 'httparty'

class PagesController < ApplicationController

  def append_names(times_array) #adiciona os nomes de alguns times que tem nomes compostos.
    times_array.each do |time|
      if time == "PAULO/SP"
        time.prepend("SÂO ")
      elsif time == "GAMA/RJ"
        time.prepend("VASCO DA ")
      elsif time == "PRETA/SP"
        time.prepend("PONTE ")
      elsif time == "CORRÊA/MA"
        time.prepend("SAMPAIO ")
      end
    end
    return times_array
  end

  def get_statsA #busca no site todos os percentuas de todos os times da proxima rodada serie A.
    stats_url = "http://www.mat.ufmg.br/futebol/tabela-da-proxima-rodada_seriea/"
    unparsed_stats = HTTParty.get(stats_url)
    parsed_stats = Nokogiri::HTML(unparsed_stats)
    pontos = parsed_stats.css('td').map(&:text)
    confrontosA = pontos.each_slice(5).to_a
    @odds_hashA = []
    confrontosA.each do |confronto|
      @odds_hashA << {
        confronto[0] => confronto[1],
        confronto[4] => confronto[3]
      }
    end
    @odds_hashA
  end

  def get_statsB #busca no site todos os percentuas de todos os times da proxima rodada serie B.
    stats_url = "http://www.mat.ufmg.br/futebol/tabela-da-proxima-rodada-serie-b/"
    unparsed_stats = HTTParty.get(stats_url)
    parsed_stats = Nokogiri::HTML(unparsed_stats)
    pontos = parsed_stats.css('td').map(&:text)
    confrontosB = pontos.each_slice(5).to_a
    @odds_hashB = []
    confrontosB.each do |confronto|
      @odds_hashB << {
        confronto[0] => confronto[1],
        confronto[4] => confronto[3]
      }
    end
    @odds_hashB
  end

  def joined_stats_hash #join serie A e B num só array com todos os hashes.
    @all_matches = []
    get_statsA.each do |get_stat|
      @all_matches << get_stat
    end
    get_statsB.each do |get_stat|
      @all_matches << get_stat
    end
    @all_matches
  end
  def apply_odds(team) #retorna o percentual de chances de vitória conforme o time.
    odds = joined_stats_hash
    @percentage = ""
    odds.each do |odd|
      if odd.key?(team)
        @percentage = odd.fetch(team)
      end
    end
    @percentage
  end

  def each_team_odd #cria um array com as chances dos times em ordem para exibir na view
    @team_odds = []
    teams = append_names(@times)
    teams.each do |team|
      @team_odds << team
      @team_odds << apply_odds(team[0..-4])
    end
    @team_odds
  end

  def home #busca os jogos do próximo premio da loteria esportiva.
    url = "http://loterias.caixa.gov.br/wps/portal/loterias/landing/loteca/programacao"

    html_file = HTTParty.get(url)
    html_doc = Nokogiri::HTML(html_file)
    @times = []
    @jogos = html_doc.css('tbody').text
    @jogos.split.each do |jogo|
      if jogo.length > 2 && jogo != "Sábado" && jogo != "Domingo"
        if jogo.include? "/"
          @times << jogo
        end
      end
    append_names(@times) #home retorna array com confrontos em sequencia. array[0] joga contra array[1] e etc.
    end
    joined_stats_hash
    each_team_odd
  end
end
