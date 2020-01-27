def capture_out(&_block)
  original_stdout = $stdout
  original_stderr = $stderr
  $stdout = fakeout = StringIO.new
  $stderr = fakeerr = StringIO.new

  begin
    yield
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  [fakeout.string, fakeerr.string]
end

def assert_ok(task_name)
  capture_out do
    Rake::Task[task_name].invoke
  end
end

def assert_error(task_name, exit_code = 1)
  result = assert_raises SystemExit do
    capture_out do
      Rake::Task[task_name].invoke
    end
  end
  assert_equal exit_code, result.status
end
