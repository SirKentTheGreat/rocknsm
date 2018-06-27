# Put this in /usr/share/bro/site/scripts
# And add a @load statement to the /usr/share/bro/site/local.bro script

@load Apache/Kafka/logs-to-kafka

redef Kafka::topic_name = "bro-raw";
redef Kafka::json_timestamps = JSON::TS_ISO8601;
redef Kafka::tag_json = T;
redef Kafka::kafka_conf = table(
    ["metadata.broker.list"] = "172.16.1.100:9092"
);


# Enable bro logging to kafka for all logs
event bro_init() &priority=-5
{
    for (stream_id in Log::active_streams)
    {
        if (|Kafka::logs_to_send| == 0 || stream_id in Kafka::logs_to_send)
        {
            local filter: Log::Filter = [
                $name = fmt("kafka-%s", stream_id),
                $writer = Log::WRITER_KAFKAWRITER,
                $config = table(["stream_id"] = fmt("%s", stream_id))
            ];

            Log::add_filter(stream_id, filter);
        }
    }
}
