skel.init({
	reset: 'full',
	containers: 1200,
	breakpoints: {
		large: {
			media: '(min-width: 1000px)',
			containers: '80%',
			grid: {
				gutters: "2.5em"
			}
		},
		medium: {
			media: '(min-width: 600px) and (max-width: 999px)',
			containers: '85%'
		},
		small: {
			media: '(max-width: 599px)',
			containers: '90%'
		}
	}
});
