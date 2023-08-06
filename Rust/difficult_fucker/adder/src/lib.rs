pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }

    #[test]
    fn another() {
        let result = "what the fuck";
        let target = "hloy";
        assert!(result.contains("pat"), "你的代码有问题 {}   是没有{}", target, result);
    }

    #[test]
    #[should_panic(expected = "Guess what ")]
    fn ggg_100() {
        panic!("holy");
    }
}
