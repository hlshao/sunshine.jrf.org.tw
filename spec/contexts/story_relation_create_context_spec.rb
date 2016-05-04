require 'rails_helper'

describe StoryRelationCreateContext do
  let!(:story) { FactoryGirl.create :story, defendant_names: ["defendant"], lawyer_names: ["lawyer"], judges_names: ["judge"] }
  subject { described_class.new(story) }

  context "create defendant" do
    let!(:defendant) { FactoryGirl.create :defendant, name: "defendant"}

    it { expect { subject.perform(story.defendant_names.first) }.to change { defendant.story_relations.count } }
  end

  context "create lawyer" do
    let!(:lawyer) { FactoryGirl.create :lawyer, name: "lawyer"}

    it { expect { subject.perform(story.lawyer_names.first) }.to change { lawyer.story_relations.count } }
  end

  context "create judge" do
    let!(:judge) { FactoryGirl.create :judge, name: "judge"}

    it { expect { subject.perform(story.judges_names.first) }.to change { judge.story_relations.count } }
  end

  context "create main judge" do
    let!(:judge) { FactoryGirl.create :judge, name: "judge"}
    before { story.update_attributes(main_judge: judge) }

    it { expect { subject.perform(story.main_judge.name) }.to change { judge.story_relations.count } }
  end

  context "name not in story" do
    it { expect(subject.perform("xxx")).to be_falsey }
  end

  context "name has many people" do
    let!(:judge) { FactoryGirl.create_list :judge, 2, name: "judge"}
    it { expect(subject.perform(story.judges_names.first)).to be_falsey }
  end
end