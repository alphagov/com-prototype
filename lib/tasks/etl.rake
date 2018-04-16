namespace :etl do
  desc 'Run ETL master process'
  task master: :environment do
    ETL::MasterProcessor.process
  end

  desc 'Populate GA metrics for a date'
  task :ga, [:date] => [:environment] do |_t, args|
    date = args[:date]
    ETL::GA.process(date: date.to_date)
  end
end
