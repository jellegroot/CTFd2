CTFd.plugin.run((_CTFd) => {
    const $ = _CTFd.lib.$
    
    const MAX_BONUS_FIELDS = 3; // Only allow top 3 (1st, 2nd, 3rd)
    
    // https://stackoverflow.com/questions/13627308/add-st-nd-rd-and-th-ordinal-suffix-to-a-number/13627586#13627586
    function ordinalize(i) {
		var j = i % 10,
		    k = i % 100;
		if (j == 1 && k != 11) {
		    return i + "st";
		}
		if (j == 2 && k != 12) {
		    return i + "nd";
		}
		if (j == 3 && k != 13) {
		    return i + "rd";
		}
		return i + "th";
	}
    
    let bonus_points_div = $(".bonus-points");
    let initialized = false;
    
    function update_bonus_points() {
    	let inputs = bonus_points_div.find(".bonus-points-val");
        let last_filled = -1;
    	inputs.each(function() {
    		if ($(this).find("input").val() !== '') {
    			let index = $(this).data('index');
    			if (index > last_filled)
    				last_filled = index;
    		}
    	});
    	
    	// Remove extra fields beyond last_filled + 1 OR beyond MAX_BONUS_FIELDS
    	inputs.each(function() {
    		let index = $(this).data('index');
    		if (index > last_filled + 1 || index >= MAX_BONUS_FIELDS) {
    			$(this).remove();
    		}
    	});
    	
    	// Only add a new field if we haven't reached MAX_BONUS_FIELDS
    	inputs = bonus_points_div.find(".bonus-points-val");
    	let index = inputs.length;
    	
    	if (index < MAX_BONUS_FIELDS && index === last_filled + 1) {
	    	bonus_points_div.append(`
<div class="form-group bonus-points-val" data-index="${index}">
		<label for="value">Bonus points for ${ordinalize(index + 1)} solve<br>
			<small class="form-text text-muted">
				The award for the ${ordinalize(index + 1)} team to solve the challenge
			</small>
		</label>
		<input type="number" class="form-control" name="first_blood_bonus[${index}]" min="0">
	</div>
`);
	    }
    }
    
    bonus_points_div.on("change", "input", update_bonus_points);
    
    // Initialize with first field only
    if (!initialized) {
        initialized = true;
        update_bonus_points();
    }
});
