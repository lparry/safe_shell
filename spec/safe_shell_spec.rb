require 'safe_shell'

describe "SafeShell" do

  it "should return the output of the command" do
    SafeShell.execute("echo", "Hello, world!").should == "Hello, world!\n"
  end

  it "should safely handle dangerous characters in command arguments" do
    SafeShell.execute("echo", ";date").should == ";date\n"
  end

  it "should set $? to the exit status of the command" do
    SafeShell.execute("test", "a", "=", "a")
    $?.exitstatus.should == 0

    SafeShell.execute("test", "a", "=", "b")
    $?.exitstatus.should == 1
  end

  it "should augment the returned string with the exit status" do
    SafeShell.execute('false').exitstatus.should == 1
    SafeShell.execute('true').exitstatus.should == 0
  end

  it "should have unique exit statuses for each returned string" do
    false_result = SafeShell.execute('false')
    true_result = SafeShell.execute('true')

    false_result.exitstatus.should == 1
    true_result.exitstatus.should == 0
  end

  it "should augment the returned string with a succeeded? method" do
    SafeShell.execute('false').succeeded?.should be_false
    SafeShell.execute('true').succeeded?.should be_true
  end

  it "should have unique succeeded? for each returned string" do
    false_result = SafeShell.execute('false')
    true_result = SafeShell.execute('true')

    false_result.succeeded?.should be_false
    true_result.succeeded?.should be_true
  end

  it "should handle a Pathname object passed as an argument" do
    expect { SafeShell.execute("ls", Pathname.new("/tmp")) }.should_not raise_error
  end

  context "output redirection" do
    before do
      File.delete("tmp/output.txt") if File.exists?("tmp/output.txt")
    end

    it "should let you redirect stdout to a file" do
      SafeShell.execute("echo", "Hello, world!", :stdout => "tmp/output.txt")
      File.exists?("tmp/output.txt").should be_true
      File.read("tmp/output.txt").should == "Hello, world!\n"
    end

    it "should let you redirect stderr to a file" do
      SafeShell.execute("cat", "tmp/nonexistent-file", :stderr => "tmp/output.txt")
      File.exists?("tmp/output.txt").should be_true
      File.read("tmp/output.txt").should == "cat: tmp/nonexistent-file: No such file or directory\n"
    end
  end

end
