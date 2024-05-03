/// Represents the policy for handling overflow of non-flexible areas within
/// a container.
enum SizeOverflowPolicy { shrinkFirst, shrinkLast }

/// Represents the policy for handling cases where the total size of
/// non-flexible areas within a container is smaller than the available space.
enum SizeUnderflowPolicy { stretchFirst, stretchLast, stretchAll }

/// Represents the order in which the minimum size of the areas is recovered.
enum MinSizeRecoveryPolicy { firstToLast, lastToFirst }
