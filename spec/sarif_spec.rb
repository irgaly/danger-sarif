# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerSarif do
    it "should be a plugin" do
      expect(Danger::DangerSarif.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @sarif = @dangerfile.sarif
      end

      describe "parse fixtures" do
        describe "with android-lint.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/android-lint.sarif", base_dir: "/Users/user_name")
          }
          it "have a result" do
            expect(results.size).to eq 1
          end
          it "exact result" do
            expect(results[0].message).to eq "Duplicate id @+id/view_id, defined or included multiple times in layout/my_layout.xml: [layout/my_layout.xml defines @+id/view_id, layout/my_layout.xml => layout/my_layout2.xml defines @+id/view_id]"
            expect(results[0].file).to eq "app/src/main/res/layout/my_layout.xml"
            expect(results[0].line).to eq 10
          end
        end
        describe "with detekt.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/detekt.sarif",  base_dir: "/Users/user_name")
          }
          it "have a result" do
            expect(results.size).to eq 1
          end
          it "exact result" do
            expect(results[0].message).to eq "This expression contains a magic number. Consider defining it to a well named constant."
            expect(results[0].file).to eq "app/src/main/kotlin/MyClass.kt"
            expect(results[0].line).to eq 10
          end
        end
        describe "with ktlint.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/ktlint.sarif", base_dir: "/Users/user_name")
          }
          it "have a result" do
            expect(results.size).to eq 1
          end
          it "result is a Error" do
            expect(results[0].instance_of?(DangerSarif::Error)).to be true
          end
          it "exact result" do
            expect(results[0].message).to eq "Error Message from ktlint"
            expect(results[0].file).to eq "project/app/src/main/kotlin/File.kt"
            expect(results[0].line).to eq 10
          end
        end
        describe "with qodana-community-android.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/qodana-community-android.sarif")
          }
          it "have a result" do
            expect(results.size).to eq 1
          end
          it "exact result" do
            expect(results[0].message).to eq "Function \"GreetingPreview\" is never used"
            expect(results[0].file).to eq "app/src/main/kotlin/com/example/myapplication/MainActivity.kt"
            expect(results[0].line).to eq 42
          end
        end
        describe "with qodana-community-android-short.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/qodana-community-android-short.sarif")
          }
          it "empty result" do
            expect(results.size).to eq 0
          end
        end
        describe "with qodana-community-android.sarif" do
          subject(:results) {
            @sarif.parse("spec/fixtures/rubocop-code-scanning.sarif")
          }
          it "have a result" do
            expect(results.size).to eq 1
          end
          it "exact result" do
            expect(results[0].message).to eq "Style/FrozenStringLiteralComment: Missing frozen string literal comment."
            expect(results[0].file).to eq "Dangerfile"
            expect(results[0].line).to eq 1
          end
        end
      end
    end
  end
end
