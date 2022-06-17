# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Npc do
    let(:player) { Game.player }

    let(:input) { '1' }

    subject(:npc) do
      described_class.new(name: 'Test NPC')
    end

    before do
      allow($stdin).to receive(:getch).and_return(input)
    end

    describe 'dialog' do
      context 'when an informational dialog' do
        subject(:npc) do
          described_class.new(name: 'Test NPC with Dialog', dialogs: {
                                'How are you?': 'I am well, thanks.'
                              })
        end

        it 'NPC says the phrase' do
          expect { player.interact_with(npc) }.to output(/How are you\?/).to_stdout
        end
      end

      context 'when multiple options dialog' do
        subject(:npc) do
          described_class.new(name: 'Test NPC with multiple Dialogs', dialogs: {
                                'How are you?': {
                                  'Fine, thanks.': 'Great!',
                                  'Not so great.': 'Sorry to hear that.'
                                }
                              })
        end

        it 'outputs the first option' do
          expect { player.interact_with(npc) }.to output(/1.+\) Fine, thanks\./).to_stdout
        end

        it 'outputs the second option' do
          expect { player.interact_with(npc) }.to output(/2.+\) Not so great\./).to_stdout
        end

        context 'when selecting the first option' do
          it 'player replies' do
            expect { player.interact_with(npc) }.to output(/Nigel.+: Fine, thanks\./).to_stdout
          end

          it 'NPC replies again' do
            expect { player.interact_with(npc) }.to output(/#{npc.name}.+: Great!/).to_stdout
          end
        end

        context 'when selecting the second option' do
          let(:input) { '2' }

          before do
            allow($stdin).to receive(:getch).and_return('2')
          end

          it 'player replies' do
            expect { player.interact_with(npc) }.to output(/Nigel.+: Not so great\./).to_stdout
          end

          it 'NPC replies again' do
            expect { player.interact_with(npc) }.to output(/#{npc.name}.+: Sorry to hear that\./).to_stdout
          end
        end
      end
    end
  end
end
