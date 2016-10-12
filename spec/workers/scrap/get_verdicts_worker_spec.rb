require "rails_helper"

RSpec.describe Scrap::GetVerdictsWorker, type: :worker do
  subject { described_class.new.perform }

  it { expect { subject }.to change_sidekiq_jobs_size_of(Scrap::GetVerdictsContext, :perform) }
end
