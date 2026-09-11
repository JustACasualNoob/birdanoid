export type StateContext = {
	upPressed: boolean,
	upHeld: boolean,
	boostHeld: boolean,
	tilt: number,
	forwardIntent: number,
	moveDir: number,
	groundDist: number,
	groundNormal: Vector3,
	groundPos: Vector3,
	grounded: boolean,
	state: string?,
}

return {}