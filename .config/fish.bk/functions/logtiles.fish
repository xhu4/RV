function logtiles

avlog dump --output_format PRETTYPROTO --topic global_pose --log_id "$argv" | grep -A2 frame_id | grep data | uniq

end
