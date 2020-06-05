# Scroll Mechanics
This is an example of a simple scroll view mechanics implementation.

### Important
I use single animation for `contentOffset` to simplify the example:
```swift
contentOffsetAnimation = TimerAnimation(
    duration: duration,
    animations: { [weak self] _, time in
        self?.contentOffset = parameters.value(at: time)
    },
    completion: { [weak self] finished in
        guard finished && intersection != nil else { return }
        let velocity = parameters.velocity(at: duration)
        self?.bounce(withVelocity: velocity)
    })

```

In the production you should use a separate animation for each of the coordinates (x and y) to achieve correct behaviour.
