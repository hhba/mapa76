# encoding: utf-8

require 'test_helper'
require 'stringio'

describe AnalyzerClient do
  before do
    @str = "Ernesto Guevara fue un guerrillero militante de el Movimiento 26 de Julio que participó en la revolución cubana."
    @analyzed_str = <<-EOM
Ernesto_Guevara ernesto_guevara NP00SP0 1
fue ser VSIS3S0 0.935924
un uno DI0MS0 0.987295
guerrillero guerrillero NCMS000 0.5927
militante militante AQ0CS0 0.45727
de de SPS00 0.999984
el el DA0MS0 1
Movimiento movimiento NP00O00 1
26_de_Julio [??:26/7/??:??.??:??] W 1
que que PR0CN000 0.562517
participó participar VMIS3S0 1
en en SPS00 1
la el DA0FS0 0.972269
revolución revolución NCFS000 1
cubana cubano AQ0FS0 0.65705
. . Fp 1
EOM
  end

  describe "#tokens" do
    it 'normal' do
      analyzer_client = AnalyzerClient.new @str
      analyzer_client.expects(:call).returns(@analyzed_str.split)
      tokens = analyzer_client.tokens.to_a
      tokens[0].pos.must_equal 0
      tokens[1].pos.must_equal 16
      tokens[2].pos.must_equal 20
      tokens[3].pos.must_equal 23
      tokens[4].pos.must_equal 35
      tokens[5].pos.must_equal 45
    end
  end

  describe '#pre_tokens' do
    it '' do
      analyzer_client = AnalyzerClient.new @str
      analyzer_client.expects(:call).returns(@analyzed_str.split)
      analyzer_client.pre_tokens.first.form.must_equal "Ernesto_Guevara"
    end
  end

  describe '#parse_token_line' do
    it '' do
      analyzer_client = AnalyzerClient.new('string')
      token = analyzer_client.parse_token_line("Ernesto_Guevara ernesto_guevara NP00SP0 1")
      token.form.must_equal "Ernesto_Guevara"
      token.lemma.must_equal "ernesto_guevara"
      token.tag.must_equal "NP00SP0"
      token.prob.must_equal 1.0
    end
  end

  describe '#call' do
    before do
      @stdout = StringIO.new @analyzed_str
    end

    it 'normal' do
      stdout = @stdout
      stderr = mock(readlines: [])
      stdin = IO.new 1
      Open3.expects(:popen3).returns([stdin, @stdout, stderr])
      analyzer_client = AnalyzerClient.new(@str)
      output = analyzer_client.call

      output.length.must_equal 16
      output.first.must_equal 'Ernesto_Guevara ernesto_guevara NP00SP0 1'
    end

    it 'with error' do
      stdout = @stdout
      stderr = mock(readlines: ["error"])
      stdin = IO.new 1
      Open3.expects(:popen3).returns([stdin, @stdout, stderr])
      analyzer_client = AnalyzerClient.new(@str)
      lambda {
        analyzer_client.call
      }.must_raise(AnalyzerClient::ExtractionError)
    end
  end
end
