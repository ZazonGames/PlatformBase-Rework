#define Create_0
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Variables

    image_speed = 0;

    // -- Speeds
    xSpeed = 0;             // -- Horizontal speed
    ySpeed = 0;             // -- Vertical speed (air)

    ground = false;         // -- Grounded status

    // -- Slopes and collision
    slopeHeight = 0;        // -- Slope height used while going up
    terrainID = 0;          // -- ID of the meeting terrain
    terrainCurrent = "";    // -- Type of terrain being encountered (solid or platform)
    terrainAngle = 0;       // -- Angle of the terrain being encountered

    // -- Draw coordinates
    drawX = x;
    drawY = y;
#define Step_0
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Main movement

    // -- Main movement
    var i;

    if (ground && scrCollisionMain(x, y + 5, collisionSolid) &&
        !scrCollisionMain(x + xSpeed, y, collisionSolid) &&
        !scrCollisionMain(x + xSpeed, y + 1, collisionSolid))
    {
        x += xSpeed;

        for (i = 0; i < floor(abs(xSpeed)) + 2; i += 1)
        {
            // -- Go down
            if (!(scrCollisionMain(x, y + 1, collisionSolid)))
            {
                y += 1;
            }
        }
    }
    else // -- Go up
    {
        // -- Check if is meeting a solid
        var collisionMain;
        collisionMain = scrCollisionMain(x + xSpeed, y, collisionSolid);

        if (collisionMain)
        {
            slopeHeight = 0;

            for (i = 0; i < floor(abs(xSpeed)) + 2; i += 1)
            {
                // -- Keep adding 1 to slopeHeight until it's value is greater than our slope height or until the statement isn't true
                var collisionSlope;
                collisionSlope = scrCollisionMain(x + xSpeed, y - slopeHeight, collisionSolid);

                if (collisionSlope && slopeHeight <= 4)
                {
                    slopeHeight += 1;
                }
            }

            // -- Check if we are colliding a wall and not a slope
            var collisionWall;
            collisionWall = scrCollisionMain(x + xSpeed, y - slopeHeight, collisionSolid);

            if (collisionWall)
            {
                //for (i = 0; i < 2 + abs(xSpeed); i += 1)
                {
                    // -- Move up with the slope x
                    var collisionX;
                    collisionX = scrCollisionMain(x + sign(xSpeed), y, collisionSolid);

                    if (!(collisionX))
                    {
                        x += sign(xSpeed);
                    }
                }
                xSpeed = 0;
            }
            else // -- Otherwise, we are moving up a slope
            {
                y -= slopeHeight;
            }
        }

        // -- Approach to the xSpeed
        x += xSpeed;
    }

    for (i = 0; i < abs(ySpeed) + 1; i += 1)
    {
        // -- Vertical movement
        var collisionVertical;
        collisionVertical = scrCollisionMain(x, y + ySpeed, parSolid);

        if (collisionVertical)
        {
            // -- Leave the solid
            var collisionLeave;
            collisionLeave = !(scrCollisionMain(x, y + sign(ySpeed), parSolid));

            if (collisionLeave)
            {
                y += sign(ySpeed);
            }
            ySpeed = 0;
        }
    }

    // -- Approach to the ySpeed
    y += ySpeed;
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Vertical movement

    switch(ground)
    {
        // -- In mid air
        case 0:
            ySpeed = scrApproach(ySpeed, 8, 0.23);
            // -- Land
            if (scrCollisionMain(x, y + 4, collisionSolid) && ySpeed >= 0)
            {
                ground = true;
                /*if (scrCollisionMain(x - 1, y + 4, collisionSolid) || scrCollisionMain(x + 1, y + 4, collisionSolid))
                {
                    scrPhysicsAngleSet(32, xSpeed)
                }
                xSpeed -= dsin(terrainAngle) * ySpeed;
                */
                ySpeed = 0;
            }
        break;

        // -- In ground
        case 1:
            // -- Leave the ground
            if (!scrCollisionMain(x, y + 4, collisionSolid))
            {
                ground = false;
            }
        break;
    }


    //xSpeed = xprevious - x
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Collision with other objects

    var near;
    near = instance_place(x, y, parInteractable);

    // -- Unclip from the object
    if (near != noone)
    {
        if ((place_meeting(bbox_left, y - 16, parTerrain) && scrPhysicsReturnDir(near) <= 0) || (place_meeting(bbox_right, y - 16, parTerrain) && scrPhysicsReturnDir(near) > 0))
        {
            // -- Don't push if the object is being pushed towards a wall
            exit;
        }
        else
        {            
            // -- Check if the object is touching a wall or another object
            x -= sign(near.x - x);
            y -= sign(near.y - y);
        
            xSpeed -= sign(near.x - x);
        }
    }
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Physics

    // -- Getting stuck in a wall
    if (slopeHeight == 5)
    {
        // -- Leave the ground
        if (place_meeting(x, y - 1, parTerrain) || place_meeting(x, y, parTerrain))
        {
            y -= 1;
        }


        if (place_meeting(x - sign(xprevious - x), y - sign(yprevious - y), parTerrain))
        {
            // -- Check for free space
            if (collision_point(x + 16, y, parTerrain, 0, 1) == false)
            {
                x -= 2;
                y -= 0.5;
            }
            else
            {
                x += 2;
                y -= 0.5;
            }
        }
        else
        {
            slopeHeight = 0;
        }
    }

    if (ground == true)
    {
        scrPhysicsAngleSet(32, xSpeed)
    }

    // -- Gain or loose slope speed
    if xSpeed < 0
    {
        if terrainAngle > 180 xSpeed -= 0.07*dsin(terrainAngle);
        else if terrainAngle < 180 xSpeed -= 0.2*dsin(terrainAngle);
    }
    else if xSpeed > 0
    {
        if terrainAngle < 180 xSpeed -= 0.07*dsin(terrainAngle);
        else if terrainAngle > 180 xSpeed -= 0.2*dsin(terrainAngle);
    }

    // -- Loose speed
    xSpeed -= min(abs(xSpeed), 0.04) * sign(xSpeed);

    image_angle += xSpeed*2;
#define Draw_0
/*"/*'/**//* YYD ACTION
lib_id=1
action_id=603
applies_to=self
*/
/// -- Draw

    drawX = lerp(drawX, x, 0.18 + abs(xSpeed)/25);
    drawY = lerp(drawY, y, 0.18 + abs(xSpeed)/25);

    draw_sprite_ext(sprite_index, 0, drawX, drawY, image_xscale, image_yscale, image_angle, image_blend, image_alpha)
