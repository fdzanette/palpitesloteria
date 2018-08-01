require 'nokogiri'
require 'httparty'

class PagesController < ApplicationController
  def append_names(times_array)
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

  def get_stats
    stats_url = "http://www.mat.ufmg.br/futebol/tabela-da-proxima-rodada_seriea/"
    unparsed_stats = HTTParty.get(stats_url)
    parsed_stats = Nokogiri::HTML(unparsed_stats)
    @pontos = parsed_stats.css('td').map(&:text)
    @confrontos = @pontos.each_slice(5).to_a
    @odds_hash = []
    @confrontos.each do |confronto|
      @odds_hash << {
        confronto[0] => confronto[1],
        confronto[4] => confronto[3]
      }
    end
    @odds_hash
  end

  def display_odds
    odds = get_stats

    odds.each do |odd|

    end
  end

  def home
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
    append_names(@times)
    end
    get_stats
  end
end
