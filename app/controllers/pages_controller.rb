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
      end
    end
    return times_array
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
  end
end
