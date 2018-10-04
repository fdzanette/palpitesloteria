require 'nokogiri'
require 'httparty'

class PagesController < ApplicationController

  def fetch_games #busca os jogos do próximo premio da loteria esportiva.
    url = "https://www.guiadaloteria.com.br/programacao-da-loteca.html"

    html_file = HTTParty.get(url)
    html_doc = Nokogiri::HTML(html_file)
    @times = []
    @jogos = html_doc.css('tbody').text
    @jogos.split.each do |jogo|
      if jogo.length > 2
        if jogo.include? "/"
          @times << jogo
        end
      end
    append_names(@times) #home retorna array com confrontos em sequencia. array[0] joga contra array[1] e etc.
    end
  end

  def append_names(times_array) #adiciona os nomes de alguns times que tem nomes compostos.
    times_array.each do |time|
      if time == "PAULO/SP"
        time.prepend "SÃO "
      elsif time == "GAMA/RJ"
        time.prepend("VASCO DA ")
      elsif time == "PRETA/SP"
        time.prepend("PONTE ")
      elsif time == "CORRÊA/MA"
        time.prepend("SAMPAIO ")
      elsif time == "BRASIL/RS"
        time.replace "BRASIL DE PELOTAS/RS"
      elsif time == "BENTO/SP"
        time.prepend "SÃO "
      elsif time == "ESPORTE/MG"
        time.prepend "BOA "
      elsif time == "NOVA/MG" || time == "NOVA/GO"
        time.prepend "VILA "
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
      confronto[0].nil? ? team_key1 = confronto[0] : team_key1 = confronto[0].strip
      confronto[4].nil? ? team_key2 = confronto[4] : team_key2 = confronto[4].strip
      @odds_hashA << {
        team_key1 => confronto[1],
        team_key2 => confronto[3]
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

  def loteca_games #separa do array all_matches apenas as probabilidades em ordem para exibir na view.
    all_odds = each_team_odd
    @odds_array = []
    all_odds.each do |odds|
      if odds.length <= 5
        @odds_array << odds
      end
    end
    @odds_array
  end

  def generate_score #gera placar conforme as probabilidades de vitória de cada time
    games = loteca_games
    @scores = []
    i = 0
    n = 1
    games.each do |game|
      while i <= 26
        if games[i].to_f == 0.0 && games[n].to_f == 0.0
          @scores << "- x -"
        elsif games[i].to_f > 2 * games[n].to_f
          @scores << "2 x 0"
        elsif games[i].to_f > games[n].to_f && games[i].to_f < 1.05 * games[n].to_f || games[n].to_f > games[i].to_f && games[n].to_f < 1.05 * games[i].to_f
          @scores << "1 x 1"
        elsif games[i].to_f > games[n].to_f
          @scores << "1 x 0"
        elsif games[i].to_f * 2 < games[n].to_f
          @scores << "0 x 2"
        elsif games[i].to_f < games[n].to_f
          @scores << "0 x 1"
        end
        i += 2
        n += 2
      end
    end
    @scores
  end

  def eliminate_duplicate_scores #muda os placares que estão repetidos + de 3 vezes.
    @new_scores = []
    @refined_scores = generate_score
    @refined_scores.each_with_index do |score, i|
      @new_scores[i] = score
      if @new_scores.count("1 x 0") + @new_scores.count("0 x 1")  > 3
        if @new_scores[i] == "1 x 0"
          @new_scores[i] = "2 x 1"
          if @new_scores.count("2 x 1") + @new_scores.count("1 x 2")  > 3
            @new_scores[i] = "3 x 2"
          end
        elsif @new_scores[i] == "0 x 1"
          @new_scores[i] = "1 x 2"
          if @new_scores.count("2 x 1") + @new_scores.count("1 x 2")  > 3
            @new_scores[i] = "2 x 3"
          end
        end
      elsif @new_scores.count("2 x 0") + @new_scores.count("0 x 2")  > 3
        if @new_scores[i] == "2 x 0"
          @new_scores[i] = "3 x 1"
        elsif @new_scores[i] == "0 x 2"
          @new_scores[i] = "1 x 3"
        end
      end
    end
    @new_scores
  end

  def home
    fetch_games
    each_team_odd
    eliminate_duplicate_scores
  end

end
