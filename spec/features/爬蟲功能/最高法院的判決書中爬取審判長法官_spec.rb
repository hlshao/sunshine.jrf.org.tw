require 'rails_helper'

describe '從最高法院的判決書中爬取審判長法官，並且檢查建立之', type: :context do

  let!(:court) { create :court, code: 'TPS', scrap_name: '最高法院' }
  let!(:court1) { create :court, code: 'TPH', scrap_name: '臺灣高等法院' }

  context '來自最高法院的判決書' do
    let!(:orginal_data) { File.open("#{Rails.root}/spec/fixtures/scrap_data/highest_verdict.htm") }
    let!(:verdict_content) { File.read("#{Rails.root}/spec/fixtures/scrap_data/highest_verdict_content.txt") }
    let!(:verdict_word) { '105,台上,1159' }
    let!(:verdict_publish_date) { Time.zone.today }
    let!(:verdict_story_type) { '刑事' }
    subject { Scrap::ImportVerdictContext.new(court, orginal_data, verdict_content, verdict_word, verdict_publish_date, verdict_story_type).perform }

    context '最高法院的法官列表中，姓名已存在' do
      let!(:judge) { create :judge, name: '陳宗鎮', court: court }

      context '其他法院的法官列表中，姓名已存在' do
        let!(:judge1) { create :judge, name: '陳宗鎮', court: court1 }

        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end

      context '其他法院的法官列表中，姓名不存在' do
        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end
    end

    context '最高法院的法官列表中，姓名不存在' do
      context '其他法院的法官列表中，姓名已存在' do
        let!(:judge1) { create :judge, name: '陳宗鎮', court: court1 }

        it '建立新法官' do
          expect { subject }.to change { Judge.count }
        end

        it '新法官隸屬最高法院' do
          subject
          expect(Judge.last.court).to eq(court)
        end
      end

      context '其他法院的法官列表中，姓名不存在' do
        it '建立新法官' do
          expect { subject }.to change { Judge.count }
        end

        it '新法官隸屬最高法院' do
          subject
          expect(Judge.last.court).to eq(court)
        end
      end
    end
  end

  context '來自其他法院的判決書' do
    let!(:orginal_data) { File.open("#{Rails.root}/spec/fixtures/scrap_data/verdict.html") }
    let!(:verdict_content) { File.read("#{Rails.root}/spec/fixtures/scrap_data/verdict_content.txt") }
    let!(:verdict_word) { '105,上易緝,2' }
    let!(:verdict_publish_date) { Time.zone.today }
    let!(:verdict_story_type) { '刑事' }
    subject { Scrap::ImportVerdictContext.new(court1, orginal_data, verdict_content, verdict_word, verdict_publish_date, verdict_story_type).perform }

    context '最高法院的法官列表中，姓名已存在' do
      let!(:judge) { create :judge, name: '施俊堯', court: court }

      context '其他法院的法官列表中，姓名已存在' do
        let!(:judge) { create :judge, name: '施俊堯', court: court1 }

        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end

      context '其他法院的法官列表中，姓名不存在' do
        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end
    end

    context '最高法院的法官列表中，姓名不存在' do
      context '其他法院的法官列表中，姓名已存在' do
        let!(:judge) { create :judge, name: '施俊堯', court: court1 }

        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end

      context '其他法院的法官列表中，姓名不存在' do
        it '不建立新法官' do
          expect { subject }.not_to change { Judge.count }
        end
      end
    end
  end
end
