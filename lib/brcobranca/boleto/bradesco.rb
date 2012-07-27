# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Bradesco < Base # Banco BRADESCO

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :numero_documento, :maximum => 11, :message => "deve ser menor ou igual a 11 dígitos."
      validates_length_of :conta_corrente, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."
      validates_length_of :carteira, :maximum => 2, :message => "deve ser menor ou igual a 2 dígitos."

      # Nova instancia do Bradesco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "06"}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "237"
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2,'0') unless valor.nil?
      end

      # Número seqüencial utilizado para identificar o boleto.
       # @return [String] 11 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(11,'0') unless valor.nil?
      end
      
      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> ""06/00000004042-8"
      def nosso_numero_boleto
        "#{self.carteira}/#{self.numero_documento}-#{self.novo_nosso_numero_dv}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 00001448-6"
      def agencia_conta_boleto
        "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      #
      # Posição | Tamanho | Conteúdo<br/>
      # 20 a 23 | 4 |  Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando  necessário)<br/>
      # 24 a 25 | 2 |  Carteira<br/>
      # 26 a 36 | 11 |  Número do Nosso Número(Sem o digito verificador)<br/>
      # 37 a 43 | 7 |  Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)<br/>
      # 44 a 44 | 1 |  Zero<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "#{self.agencia}#{self.carteira}#{self.numero_documento}#{self.conta_corrente}0"
      end
      
      def novo_nosso_numero_dv
        return calcula_modulo( "#{self.carteira.rjust( 2, "0" )}#{self.numero_documento}" )
      end
      
      def calcula_modulo numero
        total = self.multiplicador(numero, [2,3,4,5,6,7])
        resto = total % 11
        case resto
          when 0
            return 0
          when 1
            return 'P'
          else
            return (11 - (total % 11 ) )
        end
      end
      
      def multiplicador(numero, fatores)
        total = 0
        multiplicador_posicao = 0

        numero.split(//).reverse!.each do |caracter|
          fator = fatores[multiplicador_posicao]
          total += (caracter.to_i * fator)
          multiplicador_posicao = (multiplicador_posicao < (fatores.size - 1)) ? (multiplicador_posicao + 1) : 0
        end
        return total
      end
    end
  end
end
