require 'spec_helper'

describe Emotions::Emotion do
  before do
    emotions :happy, :sad

    run_migration do
      create_table(:users, force: true)
      create_table(:pictures, force: true) do |t|
        t.integer :happy_emotions_count, default: 0
        t.integer :sad_emotions_count, default: 0
      end
    end

    emotional 'User'
    emotive 'Picture'
  end

  describe :Validations do
    describe :validate_presence_of_emotional do
      subject { Emotion.new(emotion: 'happy', emotive: Picture.create) }
      before { subject.valid? }

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors.full_messages).to eql ['Emotional can\'t be blank', 'Emotional is invalid'] }
    end

    describe :validate_presence_of_emotive do
      subject { Emotion.new(emotion: 'happy', emotional: User.create) }
      before { subject.valid? }

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors.full_messages).to eql ['Emotive can\'t be blank', 'Emotive is invalid'] }
    end

    describe :validate_inclusion_of_emotion do
      subject { Emotion.new(emotion: 'mad', emotional: User.create, emotive: Picture.create) }
      before { subject.valid? }

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors.full_messages).to eql ['Emotion is invalid'] }
    end

    describe :validate_class_of_emotive do
      subject { Emotion.new(emotion: 'happy', emotional: User.create, emotive: User.create) }
      before { subject.valid? }

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors.full_messages).to eql ['Emotive is invalid'] }
    end

    describe :validate_class_of_emotional do
      subject { Emotion.new(emotion: 'happy', emotional: Picture.create, emotive: Picture.create) }
      before { subject.valid? }

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors.full_messages).to eql ['Emotional is invalid'] }
    end
  end

  describe :Callbacks do
    describe :update_emotion_counter_on_create do
      let(:picture) { Picture.create }
      let(:user) { User.create }
      let(:emotion) { Emotion.new(emotion: 'happy', emotional: user, emotive: picture) }

      before do
        expect(picture).to receive(:update_emotion_counter).with('happy').once
        expect(user).to receive(:update_emotion_counter).with('happy').once
        expect(emotion).to receive(:update_emotion_counter).once.and_call_original
      end

      it { emotion.save! }
    end

    describe :update_emotion_counter_on_destroy do
      let(:picture) { Picture.create }
      let(:user) { User.create }
      let(:emotion) { Emotion.new(emotion: 'happy', emotional: user, emotive: picture) }

      before do
        emotion.save!
        expect(picture).to receive(:update_emotion_counter).with('happy').once
        expect(user).to receive(:update_emotion_counter).with('happy').once
        expect(emotion).to receive(:update_emotion_counter).once.and_call_original
      end

      it { emotion.destroy }
    end
  end
end
