APP_ROOT = File.expand_path("../../..", __FILE__) unless defined?(APP_ROOT)

namespace :workers do
  desc 'Gracefully reload workers (waits for jobs to finish, then restarts processes)'
  task :reload do
    signal_workers(:quit)
  end

  desc 'Immediately kill workers, cancelling any current job and re-enqueuing them'
  task :stop => :environment do
    workers = Resque.workers
    workers.each do |worker|
      # Check running job and save arguments
      if worker.state == :working
        job_class = worker.job['payload']['class'].constantize
        job_args = worker.job['payload']['args'].first
        puts "=> Re-enqueuing #{job_class} from worker #{worker.pid}"
        Resque.enqueue(job_class, job_args)
      end
    end
    signal_workers(:term)
  end

  desc 'Pause all workers (stop processing new jobs)'
  task :pause do
    signal_workers(:usr2)
  end

  desc 'Resume all workers (begin processing new jobs)'
  task :resume do
    signal_workers(:cont)
  end


  WORKERS_PID_PATH = ENV['WORKERS_PID_PATH'] || File.join(APP_ROOT, 'tmp', 'pids')


  def signal_workers(signal)
    signal = signal.upcase.to_s
    Dir[File.join(WORKERS_PID_PATH, 'resque_worker-*.pid')].each do |pidfile|
      begin
        pid = File.read(pidfile).to_i
      rescue
        puts "=> Something bad happened reading #{pidfile}: #{$!}"
        next
      end

      next if pid == 0

      begin
        puts "=> Sending #{signal} to #{pid}"
        Process.kill(signal, pid)
      rescue Errno::ESRCH
        puts "=> No such process #{pid}"
        File.delete(pidfile)
      end
    end
  end
end
