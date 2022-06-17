# frozen_string_literal: true

module BanditMayhem
  RSpec.describe Game do
    after do
      File.unlink(described_class::DEFAULT_SAVE) if File.exist?(described_class::DEFAULT_SAVE)
    end

    describe '.save' do
      let(:yaml) { class_spy('YAML') }

      before do
        allow(described_class).to receive(:player).and_return({ name: 'Test' })
        stub_const('YAML', yaml)

        described_class.save
      end

      it 'saves the game name' do
        expect(yaml).to have_received(:dump).with hash_including(name: 'default')
      end

      it 'saves to a file' do
        expect(File).to exist(described_class::DEFAULT_SAVE)
      end

      it 'saves the player data' do
        expect(yaml).to have_received(:dump).with hash_including(player: { name: 'Test' })
      end
    end

    describe '.load_save' do
      context 'when game save file exists' do
        before do
          File.write(described_class::DEFAULT_SAVE, 'name: default_save')
        end

        it 'should load the yaml' do
          expect(described_class.load_save).to eq({ name: 'default_save' })
        end
      end

      context 'when game save file does not exist' do
        it 'returns an empty hash' do
          expect(described_class.load_save).to eq({})
        end
      end
    end
  end
end
