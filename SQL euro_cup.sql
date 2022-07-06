#Q1: Write a SQL query to find the date EURO Cup 2016 started on

select min(play_date) as euro_start_day
from euro_cup_2016.match_mast

#Q2: Write a SQL query to find the number of matches that were won by penalty shootout.

With 
	number_of_matches as(
		select 
			team_id,
			count(win_lose) as won_matches,
			decided_by
		from euro_cup_2016.match_details
		where win_lose = "W" and decided_by = "P"
		group by 1)

select sum(won_matches) as number_of_matches_won_by_penalty 
from number_of_matches

#Q3: Write a SQL query to find the match number, date, and score for matches in which no 
#stoppage time was added in the 1st half.

select 
	match_no,
    play_date,
    goal_score
from euro_cup_2016.match_mast
where stop1_sec = 0
group by 1,2

#Q4: Write a SQL query to compute a list showing the number of substitutions that
#happened in various stages of play for the entire tournament.

select 
	play_schedule,
    play_half,
    count(*) as number_of_substitutions
from player_in_out
where in_out = "I"
group by 1,2
order by 1,2

#Q5: Write a SQL query to find the number of matches that were won by a single point, but
#do not include matches decided by penalty shootout.

select count(*) as normally_won_matches
from match_mast
where results = "WIN" and decided_by = "N"

#Q6: Write a SQL query to find the number of matches that were won by a single point, but
#do not include matches decided by penalty shootout.

select count(*) as normally_won_matches
from match_mast
where results = "WIN" and decided_by = "N"

#Q7: Write a SQL query to find all the venues where matches with penalty shootouts were played.

select 
	v.venue_name,
	m.decided_by
from soccer_venue v
join match_mast m
on v.venue_id = m.venue_id
where decided_by = "P"

#Q8: Write a SQL query to find the match number for the game with the highest number of
#penalty shots, and which countries played that match.

With 
	pen_shots as(
		select 
			p.match_no,
			count(p.kick_id) as penalty_shots
			c.country_name
		from penalty_shootout p
        join soccer_country c
		where p.team_id = c.country_id
		group by 1,3)

select max(penalty_shots) as highest_penalty_shots
from pen_shots  
where score_goal = "Y"

#Q9: Write a SQL query to find the goalkeeper’s name and jersey number, playing for
#Germany, who played in Germany’s group stage matches.

With
	goal_keeper as(
		select
			p.player_name,
            p.jersey_no,
            p.team_id,
            p.posi_to_play,
            m.play_stage
		from player_mast p
        join match_details m
        on p.team_id = m.team_id
        where p.posi_to_play = "GK" and  m.play_stage = "G"
        group by 1,2)

select 
	g.*,
    c.country_name    
from goal_keeper g
join soccer_country c
	on g.team_id = c.country_id
where country_name = "Germany"
order by g.player_name

#Q10: Write a SQL query to find all available information about the players under contract to
#Liverpool F.C. playing for England in EURO Cup 2016.

select p.*, c.country_name
from player_mast p 
join soccer_country c
where p.playing_club = "Liverpool" and country_name = "England"
order by p.jersey_no, p.player_name

#Q11: Write a SQL query to find the players, their jersey number, and playing club who were
#the goalkeepers for England in EURO Cup 2016.

select
	p.player_name,
    p.jersey_no,
    p.playing_club,
	p.posi_to_play,
    c.country_name
from player_mast p
join soccer_country c
on p.team_id = c.country_id
where c.country_name = "England" and p.posi_to_play = "GK"
group by 3
order by 1,2

#Q12: Write a SQL query that returns the total number of goals scored by each position on
#each country’s team. Do not include positions which scored no goals

With 
	counting_goals as(
		select
			g.team_id,
			count(g.goal_id) as number_of_goals,
			p.posi_to_play
		from goal_details g
		join player_mast p
		on g.player_id = p.player_id
		group by 3)

select g.*, c.country_name
from counting_goals g
join soccer_country c
on g.team_id = c.country_id
where number_of_goals <> 0
group by c.country_name

#Q13: Write a SQL query to find all the defenders who scored a goal for their teams

select
	p.player_id,
	p.player_name,
    p.team_id,
    p.posi_to_play,
    count(g.goal_id) as number_of_goal
from player_mast p
join goal_details g
on p.player_id = g.player_id
where posi_to_play = "DF" 
group by 1,2
having count(g.goal_id) = 1
order by 1,2

#Q14: Write a SQL query to find referees and the number of bookings they made for the
#entire tournament. Sort your answer by the number of bookings in descending order.

select 
	r.referee_id,
    r.referee_name,
    count(b.booking_time) as number_of_bookings
from referee_mast r
join player_booked b
on r.country_id = b.team_id
group by 1
order by 3 desc

#Q15: Write a SQL query to find the referees who booked the most number of players.

####PROBLEM: RANK DOESN'T WORK!

With 
	booking_num as
		(select 
			r.referee_id,
			r.referee_name,
			count(b.booking_time) as number_of_bookings
		from referee_mast r
		join player_booked b
		on r.country_id = b.team_id
		group by 1,2)
        
	,bookings_rank as
    (select 
			referee_id,
			referee_name,
			number_of_bookings,
            dense_rank() over (partition by referee_name order by number_of_bookings desc) as rank_referees_by_bookings
	 from booking_num)
     
select * from bookings_rank

#Q16: Write a SQL query to find referees and the number of matches they worked in each venue.

select
	m.referee_id,
    r.referee_name,
    v.venue_name,
	count(m.referee_id) as number_of_matches
from match_mast m
	join referee_mast r
	on m.referee_id = r.referee_id
    join soccer_venue v
	on m.venue_id = v.venue_id
group by 1,2,3

#Q17: Write a SQL query to find the country where the most assistant referees come from,
#and the count of the assistant referees

####PROBLEM: RANK DOESN'T WORK!

With 
	assistant_refs as
		(select
			count(a.ass_ref_name) as number_of_assistant_refs,
			c.country_name
		from asst_referee_mast a
		join soccer_country c
		on a.country_id = c.country_id 
		group by 2)
        
	,ref_quantity_rank as
    (select
			number_of_assistant_refs,
			country_name,
			rank() over (partition by country_name order by number_of_assistant_refs desc) as quantity_rank
		from assistant_refs)

select * from ref_quantity_rank

#Q18: Write a SQL query to find the highest number of foul cards given in one match.

With 
	foul_cards as(
		select
			match_no,
            count(*) as number_of_cards
		from player_booked
        group by 1)

select  match_no, max(number_of_cards) as highest_foul_cards
from foul_cards

#Q19: Write a SQL query to find the number of captains who were also goalkeepers.

select count(distinct player_name) as captains_aka_goalkeepers
from match_captain m
	join soccer_country c
	on m.team_id = c.country_id
	join player_mast p 
	on m.player_captain = p.player_id
where posi_to_play='GK'

#Q20: Write a SQL query to find the substitute players who came into the field in the first
#half of play, within a normal play schedule.

select
	match_no,
    country_name,
    player_name,
    play_schedule,
    play_half
from player_in_out i
	join player_mast p
	on i.player_id = p.player_id
	join soccer_country c
	on p.team_id = c.country_id
where i.in_out = "I"
and i.play_schedule = "NT"
and i.play_half = 1





    


    


			
			




    

    


